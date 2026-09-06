// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

public final class ESCasualDateParser: Parser {
  override var language: Language { .spanish }
  override var pattern: String {
    #"(?<![\p{L}\p{N}_])(?:(?<today>esta)\s+(?<thisPeriod>mañana|tarde|noche)|(?<day>ayer|mañana|hoy)(?:\s+por\s+la\s+(?<period>mañana|tarde|noche))?|(?<lastNight>anoche))(?=$|[^\p{L}\p{N}_])"#
  }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let value = try match.string(from: text, atRangeIndex: 0)
    var result = ParsedResult(ref: ref, index: match.range.location, text: value)
    let day: ChronoDate
    if let range = Range(match.range(withName: "day"), in: text) {
      switch text[range].lowercased() {
      case "ayer": day = try ref.added(-1, .day)
      case "mañana": day = try ref.added(1, .day)
      case "hoy": day = ref
      default: throw ChronoError.invalidSourceRange
      }
    } else if match.range(withName: "lastNight").location != NSNotFound {
      day = try ref.added(-1, .day)
      result.start.dayPeriod = DayPeriod(.night1, language: language)
    } else if match.range(withName: "today").location != NSNotFound {
      day = ref
    } else {
      throw ChronoError.invalidSourceRange
    }
    for name in ["period", "thisPeriod"] {
      guard let range = Range(match.range(withName: name), in: text) else { continue }
      let phase: DayPeriod.Phase
      switch text[range].lowercased() {
      case "mañana": phase = .morning2
      case "tarde": phase = .evening1
      case "noche": phase = .night1
      default: throw ChronoError.invalidSourceRange
      }
      result.start.dayPeriod = DayPeriod(phase, language: language)
    }
    try result.start.assign(date: day, precision: .day)
    result.tags[.esCasualDateParser] = true
    return result
  }
}
