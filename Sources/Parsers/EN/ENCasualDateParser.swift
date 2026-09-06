// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

public final class ENCasualDateParser: Parser {
  override var pattern: String {
    #"(?<![\p{L}\p{N}_])(?:today|tonight|last\s+night|tomorrow|tmr|yesterday)(?=$|[^\p{L}\p{N}_])"#
  }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let value = try match.string(from: text, atRangeIndex: 0)
    var result = ParsedResult(ref: ref, index: match.range.location, text: value)
    let word = value.split(whereSeparator: \.isWhitespace).joined(separator: " ").lowercased()
    let day: ChronoDate
    switch word {
    case "today": day = ref
    case "tomorrow", "tmr": day = try ref.added(1, .day)
    case "yesterday": day = try ref.added(-1, .day)
    case "tonight":
      day = ref
      result.start.dayPeriod = DayPeriod(.night1, language: language)
    case "last night":
      day = try ref.added(-1, .day)
      result.start.dayPeriod = DayPeriod(.night1, language: language)
    default: throw ChronoError.invalidSourceRange
    }
    try result.start.assign(date: day, precision: .day)
    result.tags[.enCasualDateParser] = true
    return result
  }
}
