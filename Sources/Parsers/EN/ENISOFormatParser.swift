// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

/// Language-neutral civil ISO dates, with an optional clock and explicit offset.
public class ENISOFormatParser: Parser {
  override var language: Language { .neutral }
  override var pattern: String {
    #"(\W|^)[0-9]{4,}-[0-9]*-[0-9]*(?:T[^\s,;!?()\[\]{}]*)?(?=\W|$)"#
  }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (value, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: value)
    result.tags[.enISOFormatParser] = true
    let fields = try NSRegularExpression(
      pattern:
        #"^([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})(?:T([0-9]{1,2}):([0-9]{1,2})(?::([0-9]{1,2})(?:\.([0-9]+))?)?(Z|[+-][0-9]{2}(?::?[0-9]{2})?)?)?$"#,
      options: .caseInsensitive)
    guard
      let parsed = fields.firstMatch(
        in: value, range: NSRange(location: 0, length: value.utf16.count)),
      parsed.range.length == value.utf16.count
    else {
      result.issues.append(.invalidComponents)
      return result
    }
    for (component, group) in [
      (ComponentUnit.year, 1), (.month, 2), (.day, 3),
      (.hour, 4), (.minute, 5), (.second, 6),
    ] where parsed.isNotEmpty(atRangeIndex: group) {
      guard let number = Int(try parsed.string(from: value, atRangeIndex: group)) else {
        throw ChronoError.invalidDate
      }
      result.start.assign(component, value: number)
    }
    if parsed.isNotEmpty(atRangeIndex: 7) {
      let fraction = try parsed.string(from: value, atRangeIndex: 7)
      if fraction.utf8.count > 3 {
        result.issues.append(.unsupportedPrecision)
      } else {
        guard
          let milliseconds = Int(fraction + String(repeating: "0", count: 3 - fraction.utf8.count))
        else { throw ChronoError.invalidDate }
        result.start.assign(.millisecond, value: milliseconds)
      }
    }
    if parsed.isNotEmpty(atRangeIndex: 8) {
      let zone = try parsed.string(from: value, atRangeIndex: 8)
      if zone.uppercased() == "Z" {
        result.start.assign(.timeZoneOffset, value: 0)
      } else if let offset = parsedTimeZoneOffset(zone) {
        result.start.assign(.timeZoneOffset, value: offset)
      } else {
        result.issues.append(.invalidTimeZone)
      }
    }
    return result
  }
}
