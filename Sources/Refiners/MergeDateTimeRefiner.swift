// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

class MergeDateTimeRefiner: Refiner {
  var PATTERN: String { "" }
  var TAGS: TagUnit { .none }

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
      guard try NSRegularExpression.isMatch(forPattern: PATTERN, in: gap) else {
        merged.append(result)
        continue
      }
      merged.removeLast()
      merged.append(try merge(date: date, clock: clock, in: text))
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

  private func merge(date: ParsedResult, clock: ParsedResult, in text: String) throws
    -> ParsedResult
  {
    var result = date
    result.index = min(date.index, clock.index)
    result.text = try text.substring(
      from: result.index,
      to: max(date.index + date.text.utf16.count, clock.index + clock.text.utf16.count))
    result.tags.merge(clock.tags) { first, _ in first }
    result.tags[TAGS] = true
    result.languages.formUnion(clock.languages)
    result.languages.insert(language)
    result.issues += clock.issues
    guard result.issues.isEmpty else { return result }
    // Repeating a time of day within several days is not one continuous interval.
    guard date.end == nil else {
      result.issues.append(.unresolvedDayPeriod)
      return result
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
