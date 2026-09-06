// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

public final class CACasualDateParser: Parser {
  override var language: Language { .catalan }
  override var pattern: String {
    #"(?<![\p{L}\p{N}_])(?:(?<today>aquesta?)\s+(?<thisPeriod>matí|tarda|nit)|(?<day>ahir|demà|avui)(?:\s+(?:pel|per\s+la|a\s+la)\s+(?<period>matí|tarda|nit))?)(?=$|[^\p{L}\p{N}_])"#
  }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let value = try match.string(from: text, atRangeIndex: 0)
    var result = ParsedResult(ref: ref, index: match.range.location, text: value)
    let day: ChronoDate
    if let range = Range(match.range(withName: "day"), in: text) {
      switch text[range].lowercased() {
      case "ahir": day = try ref.added(-1, .day)
      case "demà": day = try ref.added(1, .day)
      case "avui": day = ref
      default: throw ChronoError.invalidSourceRange
      }
    } else if match.range(withName: "today").location != NSNotFound {
      day = ref
    } else {
      throw ChronoError.invalidSourceRange
    }
    for name in ["period", "thisPeriod"] {
      guard let range = Range(match.range(withName: name), in: text) else { continue }
      let phase: DayPeriod.Phase
      switch text[range].lowercased() {
      case "matí": phase = .morning2
      case "tarda": phase = .afternoon2
      case "nit": phase = .night1
      default: throw ChronoError.invalidSourceRange
      }
      result.start.dayPeriod = DayPeriod(phase, language: language)
    }
    try result.start.assign(date: day, precision: .day)
    result.tags[.caCasualDateParser] = true
    return result
  }
}
