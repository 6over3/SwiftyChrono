// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

/// Language-neutral civil ISO dates, with an optional clock and explicit offset.
public class ENISOFormatParser: Parser {
  override var language: Language { .neutral }
  override var pattern: String {
    #"(\W|^)([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})(?:T([0-9]{1,2}):([0-9]{1,2})(?::([0-9]{1,2})(?:\.([0-9]+))?)?(?:(Z)|([+-])([0-9]{2})(?::?([0-9]{2}))?)?)?(?=\W|$)"#
  }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (value, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: value)
    result.tags[.enISOFormatParser] = true
    for (component, group) in [(ComponentUnit.year, 2), (.month, 3), (.day, 4),
      (.hour, 5), (.minute, 6), (.second, 7)] where match.isNotEmpty(atRangeIndex: group) {
      guard let number = Int(try match.string(from: text, atRangeIndex: group)) else {
        throw ChronoError.invalidDate
      }
      result.start.assign(component, value: number)
    }
    if match.isNotEmpty(atRangeIndex: 8) {
      let fraction = try match.string(from: text, atRangeIndex: 8)
      if fraction.utf8.count > 3 {
        result.issues.append(.unsupportedPrecision)
      } else {
        guard let milliseconds = Int(fraction + String(repeating: "0", count: 3 - fraction.utf8.count))
        else { throw ChronoError.invalidDate }
        result.start.assign(.millisecond, value: milliseconds)
      }
    }
    if match.isNotEmpty(atRangeIndex: 9) {
      result.start.assign(.timeZoneOffset, value: 0)
    } else if match.isNotEmpty(atRangeIndex: 10) {
      guard let hours = Int(try match.string(from: text, atRangeIndex: 11)) else {
        throw ChronoError.invalidDate
      }
      let minutes: Int
      if match.isNotEmpty(atRangeIndex: 12) {
        guard let parsed = Int(try match.string(from: text, atRangeIndex: 12)) else {
          throw ChronoError.invalidDate
        }
        minutes = parsed
      } else {
        minutes = 0 // An explicitly written whole-hour offset.
      }
      if hours > 23 || minutes > 59 {
        result.issues.append(.invalidTimeZone)
      } else {
        let sign = try match.string(from: text, atRangeIndex: 10) == "-" ? -1 : 1
        result.start.assign(.timeZoneOffset, value: sign * (hours * 60 + minutes))
      }
    }
    return result
  }
}
