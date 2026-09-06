// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

final class MergeDateTimeRefiner: Refiner {
  private let grammar: Language
  private let joiningPattern: String
  private let unresolvedPattern: String?
  private let tag: TagUnit
  private let operandFilter = UnlikelyFormatFilter()
  override var language: Language { grammar }

  private init(_ language: Language, joining: String, unresolved: String? = nil, tag: TagUnit) {
    grammar = language
    joiningPattern = "^\\s*(?:\(joining))?\\s*$"
    unresolvedPattern = unresolved.map { "^\\s*(?:\($0))\\s*$" }
    self.tag = tag
  }

  static var english: MergeDateTimeRefiner {
    .init(
      .english, joining: "T|at|on|of|,|-",
      tag: .enMergeDateAndTimeRefiner)
  }

  static var french: MergeDateTimeRefiner {
    .init(
      .french, joining: "T|à|a|de|,|-", unresolved: "vers",
      tag: .frMergeDateAndTimeRefiner)
  }

  static var german: MergeDateTimeRefiner {
    .init(.german, joining: "T|um|,|-", tag: .deMergeDateAndTimeRefiner)
  }

  static var russian: MergeDateTimeRefiner {
    .init(
      .russian, joining: "T|в|,|-", unresolved: "по|с", tag: .ruMergeDateAndTimeRefiner)
  }

  static var spanish: MergeDateTimeRefiner {
    .init(.spanish, joining: "T|a las?|al?|,|-", tag: .esMergeDateAndTimeRefiner)
  }

  static var catalan: MergeDateTimeRefiner {
    .init(.catalan, joining: "T|a les?|al?|,|-", tag: .caMergeDateAndTimeRefiner)
  }

  override func refine(
    text: String, results: [ParsedResult], opt: [OptionType: Int]
  ) throws -> [ParsedResult] {
    var merged: [ParsedResult] = []
    for result in results {
      guard let previous = merged.last else {
        merged.append(result)
        continue
      }
      let date: ParsedResult
      let clock: ParsedResult
      if isDateOnly(previous), isTimeOnly(result) {
        date = previous
        clock = result
      } else if isDateOnly(result), isTimeOnly(previous) {
        date = result
        clock = previous
      } else {
        merged.append(result)
        continue
      }
      let end = previous.index + previous.text.utf16.count
      guard end <= result.index else { throw ChronoError.invalidSourceRange }
      let gap = try text.substring(from: end, to: result.index)
      let comparison = try TemporalComparisonGrammar.connector(in: gap, language: language)
      let isUnresolved: Bool
      if let unresolvedPattern {
        isUnresolved = try NSRegularExpression.isMatch(forPattern: unresolvedPattern, in: gap)
      } else {
        isUnresolved = false
      }
      guard
        try comparison != nil || isUnresolved
          || NSRegularExpression.isMatch(forPattern: joiningPattern, in: gap)
      else {
        merged.append(result)
        continue
      }
      merged.removeLast()
      let uncertainClock =
        try comparison != nil
        && !operandFilter.isValid(text: text, result: clock, opt: opt)
      merged.append(
        try merge(
          date: date, clock: clock, in: text, comparison: comparison,
          unresolved: comparison == nil && isUnresolved || uncertainClock))
    }
    return merged
  }

  private func isDateOnly(_ result: ParsedResult) -> Bool {
    !result.start.isCertain(component: .hour)
  }

  private func isTimeOnly(_ result: ParsedResult) -> Bool {
    ![ComponentUnit.year, .month, .day, .weekday].contains { result.start.isCertain(component: $0) }
      && (result.start.isCertain(component: .hour) || result.start.dayPeriod != nil)
  }

  private func merge(
    date: ParsedResult, clock: ParsedResult, in text: String,
    comparison: TemporalComparison?, unresolved: Bool
  )
    throws
    -> ParsedResult
  {
    var result = date
    result.index = min(date.index, clock.index)
    result.text = try text.substring(
      from: result.index,
      to: max(date.index + date.text.utf16.count, clock.index + clock.text.utf16.count))
    result.tags.merge(clock.tags) { first, _ in first }
    result.tags[tag] = true
    result.languages.formUnion(clock.languages)
    result.languages.insert(language)
    result.issues += clock.issues
    result.ambiguities.formUnion(clock.ambiguities)
    if unresolved { result.issues.append(.unresolvedComposition) }
    guard result.issues.isEmpty else { return result }
    // Repeating a time of day within several days is not one continuous interval.
    guard date.end == nil else {
      result.issues.append(.unresolvedDayPeriod)
      return result
    }
    if let comparison {
      guard comparison != .unresolved, date.index < clock.index, clock.end == nil,
        clock.start.isCertain(component: .hour),
        date.start.isCertain(component: .day) || date.start.isCertain(component: .weekday)
      else {
        result.issues.append(.unresolvedComposition)
        return result
      }
      result.comparison = comparison
      var scope = date.start
      if let zone = clock.start.timeZone { scope.assign(timeZone: zone) }
      result.comparisonScope = scope
    }
    if let issue = result.start.applyClock(from: clock.start) {
      result.issues.append(issue)
      return result
    }
    if let endpoint = clock.end {
      var end = date.start
      // An introductory qualifier describes the first clock; a separately
      // written endpoint may carry its own qualifier and may cross midnight.
      end.dayPeriod = nil
      if let issue = end.applyClock(from: endpoint) {
        result.issues.append(issue)
        return result
      }
      result.end = end
      result.resolveClockQualifiers()
      guard result.issues.isEmpty else { return result }
      if var endpoint = result.end, endpoint.isDefinitelyBefore(result.start) {
        try endpoint.shiftCalendarDays(1)
        result.end = endpoint
      }
    }
    return result
  }
}
