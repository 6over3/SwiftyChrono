import Foundation

/// A calendar period supplies omitted date context; it never replaces a written date.
final class DateContextRefiner: Refiner {
  private let grammar: Language
  private let joiner: String
  override var language: Language { grammar }

  private init(_ language: Language, joiner: String) {
    grammar = language
    self.joiner = "^\\s*(?:\(joiner))?\\s*$"
  }

  static var all: [DateContextRefiner] {
    [
      .init(.english, joiner: "of|in|on|during"),
      .init(.spanish, joiner: "de|del|de la|en"),
      .init(.catalan, joiner: "de|del|de la|de l['’]|d['’]|en"),
      .init(.french, joiner: "de|du|de la|de l['’]|en"),
      .init(.german, joiner: "in|im|der|des"),
      .init(.russian, joiner: "в|во|на"),
      .init(.japanese, joiner: "の"),
      .init(.chineseSimplified, joiner: "的"),
      .init(.chinese, joiner: "的"),
    ]
  }

  override func refine(
    text: String, results: [ParsedResult], opt: [OptionType: Int]
  ) throws -> [ParsedResult] {
    var merged: [ParsedResult] = []
    for current in results {
      guard let previous = merged.last,
        previous.tags[.relativePeriodParser] == true || current.tags[.relativePeriodParser] == true,
        hasDate(previous), hasDate(current)
      else {
        merged.append(current)
        continue
      }
      let end = previous.index + previous.text.utf16.count
      guard end <= current.index else { throw ChronoError.invalidSourceRange }
      let gap = try text.substring(from: end, to: current.index)
      guard try NSRegularExpression.isMatch(forPattern: joiner, in: gap) else {
        merged.append(current)
        continue
      }
      let period: ParsedResult
      let selector: ParsedResult
      if previous.tags[.relativePeriodParser] == true {
        period = previous
        selector = current
      } else {
        period = current
        selector = previous
      }
      merged.removeLast()
      merged.append(try compose(selector: selector, period: period, in: text))
    }
    return merged
  }

  private func compose(selector: ParsedResult, period: ParsedResult, in text: String) throws
    -> ParsedResult
  {
    let index = min(selector.index, period.index)
    var result = ParsedResult(
      ref: period.ref, index: index,
      text: try text.substring(
        from: index,
        to: max(selector.index + selector.text.utf16.count, period.index + period.text.utf16.count))
    )
    result.start = selector.start
    result.end = selector.end
    result.tags = selector.tags.merging(period.tags) { first, _ in first }
    result.tags[.dateContextRefiner] = true
    result.languages = selector.languages.union(period.languages).union([language])
    result.issues = selector.issues + period.issues
    guard result.issues.isEmpty else { return result }
    do {
      let zones = Set(
        [
          selector.start.timeZone, selector.end?.timeZone, period.start.timeZone,
          period.end?.timeZone,
        ]
        .compactMap { $0 })
      guard zones.count <= 1 else { throw ParsedDateIssue.invalidTimeZone }
      if let zone = zones.first {
        result.start.assign(timeZone: zone)
        // Chrono must re-evaluate both operands in their shared zone before we
        // judge whether their dates agree. The period owns the reference calendar.
        if period.ref.calendar.timeZone != zone || selector.start.calendar.timeZone != zone {
          return result
        }
      }
      guard selector.end == nil else { throw ParsedDateIssue.unresolvedComposition }
      result.start = try result.start.resolvingDate(in: period)
    } catch let issue as ParsedDateIssue {
      result.issues.append(issue)
    }
    return result
  }

  private func hasDate(_ result: ParsedResult) -> Bool {
    !result.issues.isEmpty
      || [ComponentUnit.year, .month, .day, .weekday].contains {
        result.start.isCertain(component: $0)
      }
  }
}
