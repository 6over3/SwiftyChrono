// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

public final class ENCasualTimeParser: Parser {
  override var pattern: String {
    #"(?<![\p{L}\p{N}_])(?<value>(?:(?<today>this)\s+)?(?<period>morning|afternoon|evening|noon|midnight))(?=$|[^\p{L}\p{N}_])"#
  }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let range = match.range(withName: "value")
    guard let source = Range(range, in: text),
      let token = Range(match.range(withName: "period"), in: text)
    else { throw ChronoError.invalidSourceRange }
    var result = ParsedResult(ref: ref, index: range.location, text: String(text[source]))
    let phase: DayPeriod.Phase
    switch text[token].lowercased() {
    case "morning": phase = .morning1
    case "afternoon": phase = .afternoon1
    case "evening": phase = .evening1
    case "noon": phase = .noon
    case "midnight": phase = .midnight
    default: throw ChronoError.invalidSourceRange
    }
    if match.range(withName: "today").location != NSNotFound {
      try result.start.assign(date: ref, precision: .day)
    }
    result.start.dayPeriod = DayPeriod(phase, language: language)
    result.tags[.enCasualTimeParser] = true
    return result
  }
}
