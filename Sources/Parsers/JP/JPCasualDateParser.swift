// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

public final class JPCasualDateParser: Parser {
  override var pattern: String { "今日|当日|昨日|明日|今夜|今夕|今晩|今朝" }
  override var language: Language { .japanese }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let value = try match.string(from: text, atRangeIndex: 0)
    var result = ParsedResult(ref: ref, index: match.range.location, text: value)
    let day: ChronoDate
    switch value {
    case "明日": day = try ref.added(1, .day)
    case "昨日": day = try ref.added(-1, .day)
    case "今日", "当日", "今夜", "今夕", "今晩", "今朝": day = ref
    default: throw ChronoError.invalidSourceRange
    }
    switch value {
    case "今朝": result.start.dayPeriod = DayPeriod(.morning1, language: language)
    case "今夕": result.start.dayPeriod = DayPeriod(.evening1, language: language)
    case "今夜", "今晩": result.start.dayPeriod = DayPeriod(.night1, language: language)
    default: break
    }
    try result.start.assign(date: day, precision: .day)
    result.tags[.jpCasualDateParser] = true
    return result
  }
}
