// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

class MergeDateRangeRefiner: Refiner {
  var PATTERN: String { "" }
  var TAGS: TagUnit { .none }

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
      guard try NSRegularExpression.isMatch(forPattern: PATTERN, in: gap) else {
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
    if !isWeekday(first.start), !isWeekday(end) {
      inheritDateFields(into: &result.start, from: last.start)
      inheritDateFields(into: &end, from: first.start)
    }
    if let zone = result.start.timeZone, end.timeZone == nil {
      end.assign(timeZone: zone)
    } else if let zone = end.timeZone, result.start.timeZone == nil {
      result.start.assign(timeZone: zone)
    }
    result.end = end
    result.text = try text.substring(
      from: first.index, to: last.index + last.text.utf16.count)
    result.tags.merge(last.tags) { first, _ in first }
    result.tags[TAGS] = true
    result.languages.formUnion(last.languages)
    result.languages.insert(language)
    result.issues += last.issues
    return result
  }

  private func isWeekday(_ components: ParsedComponents) -> Bool {
    components.isCertain(component: .weekday) && !components.isCertain(component: .day)
  }

  /// Inherit omitted context, not finer precision. A month must stay a month;
  /// a whole day must not acquire the other endpoint's clock.
  private func inheritDateFields(into target: inout ParsedComponents, from source: ParsedComponents)
  {
    let fields: [ComponentUnit]
    if target.isCertain(component: .day) || target.isCertain(component: .hour) {
      fields = [.year, .month, .day]
    } else if target.isCertain(component: .month) {
      fields = [.year]
    } else {
      return
    }
    for field in fields where !target.isCertain(component: field) {
      if let value = source.knownValues[field] {
        target.assign(field, value: value)
      }
    }
  }
}
