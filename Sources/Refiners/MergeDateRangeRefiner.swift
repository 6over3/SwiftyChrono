// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

final class MergeDateRangeRefiner: Refiner {
  private let grammar: Language
  private let joiningPattern: String
  override var language: Language { grammar }

  private init(_ language: Language, joining: String) {
    grammar = language
    joiningPattern = "^\\s*(?:\(joining))\\s*$"
  }

  static var all: [MergeDateRangeRefiner] {
    [
      .init(.english, joining: "to|-"),
      .init(.french, joining: "à|a|-"),
      .init(.german, joining: "bis|-"),
      .init(.russian, joining: "до|-"),
      .init(.japanese, joining: "から|ー"),
      .init(.spanish, joining: "a|al|hasta|-"),
      .init(.catalan, joining: "a|al|fins a|-"),
      .init(.chineseSimplified, joining: "到|至|-"),
      .init(.chinese, joining: "到|至|-"),
    ]
  }

  override func refine(
    text: String, results: [ParsedResult], opt: [OptionType: Int]
  ) throws -> [ParsedResult] {
    var merged: [ParsedResult] = []
    for result in results {
      guard let previous = merged.last, previous.end == nil, result.end == nil else {
        merged.append(result)
        continue
      }
      let end = previous.index + previous.text.utf16.count
      guard end <= result.index else { throw ChronoError.invalidSourceRange }
      let gap = try text.substring(from: end, to: result.index)
      guard try NSRegularExpression.isMatch(forPattern: joiningPattern, in: gap) else {
        merged.append(result)
        continue
      }
      merged.removeLast()
      merged.append(try merge(previous, through: result, in: text))
    }
    return merged
  }

  private func merge(
    _ first: ParsedResult, through last: ParsedResult, in text: String
  ) throws -> ParsedResult {
    var result = first
    var end = last.start
    if let zone = result.start.timeZone, end.timeZone == nil {
      end.assign(timeZone: zone)
    } else if let zone = end.timeZone, result.start.timeZone == nil {
      result.start.assign(timeZone: zone)
    }
    result.end = end
    result.text = try text.substring(
      from: first.index, to: last.index + last.text.utf16.count)
    result.tags.merge(last.tags) { first, _ in first }
    result.tags[.dateRangeRefiner] = true
    result.languages.formUnion(last.languages)
    result.languages.insert(language)
    result.issues += last.issues
    result.ambiguities.formUnion(last.ambiguities)
    if first.comparison != nil || last.comparison != nil {
      result.issues.append(.unresolvedComposition)
    }
    guard result.issues.isEmpty else { return result }
    // Let Chrono re-evaluate shared relative context in a written zone before
    // assigning endpoint dates. Two independently written zones stay independent.
    if let zone = result.sharedTimeZone,
      result.ref.calendar.timeZone != zone || result.start.calendar.timeZone != zone
        || end.calendar.timeZone != zone
    {
      return result
    }
    do {
      let range = try ParsedComponents.resolvingRange(start: result.start, end: end)
      result.start = range.start
      result.end = range.end
    } catch let issue {
      result.issues.append(issue)
    }
    return result
  }
}
