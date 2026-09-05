//
//  RUTimeAgoFormatParser.swift
//  SwiftyChrono
//
//  Created by Nickolay Truhin on 06.04.2021.
//

import Foundation

// RU_TIME_UNIT_PATTERN/RU_TIME_UNIT_STRICT_PATTERN already carry the number and unit as
// their own two capture groups (mirroring ENTimeAgoFormatParser's PATTERN/STRICT_PATTERN),
// so they are spliced in directly rather than wrapped in another capturing group — an
// extra wrap would shift "number"/"unit" to groups 3/4 in casual mode while leaving them
// at 2/3 in strict mode, since the two patterns aren't structured identically.
private let PATTERN =
  "(\\W|^)" + "(?:в течении\\s*)?" + RU_TIME_UNIT_PATTERN + "(?:назад|ранее)(?=(?:\\W|$))"

private let STRICT_PATTERN =
  "(\\W|^)" + "(?:в течении\\s*)?" + RU_TIME_UNIT_STRICT_PATTERN + "назад(?=(?:\\W|$))"

public class RUTimeAgoFormatParser: Parser {
  override var pattern: String { strictMode ? STRICT_PATTERN : PATTERN }
  override var language: Language { .russian }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: matchText)
    result.tags[.ruTimeAgoFormatParser] = true
    let amount = try RelativeDateAmount(
      text: match.string(from: text, atRangeIndex: 2), language: language)
    let unit = try RelativeDateUnit(
      text: match.string(from: text, atRangeIndex: 3), language: language)
    try result.applyOffset(amount: amount, unit: unit, direction: .past)
    return result
  }
}
