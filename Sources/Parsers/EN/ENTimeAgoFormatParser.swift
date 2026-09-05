//
//  ENTimeAgoFormatParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/23/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\W|^)" + "(?:within\\s*)?"
  + "(\(EN_INTEGER_WORDS_PATTERN)|[0-9]+|an?(?:\\s*few)?|half(?:\\s*an?)?)\\s*"
  + "(seconds?|min(?:ute)?s?|hours?|weeks?|days?|months?|years?)\\s*"
  + "(?:ago|before|earlier)(?=(?:\\W|$))"

private let STRICT_PATTERN =
  "(\\W|^)" + "(?:within\\s*)?" + "([0-9]+|an?)\\s*" + "(seconds?|minutes?|hours?|days?)\\s*"
  + "ago(?=(?:\\W|$))"

public class ENTimeAgoFormatParser: Parser {
  override var pattern: String { return strictMode ? STRICT_PATTERN : PATTERN }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: matchText)
    result.tags[.enTimeAgoFormatParser] = true
    let amount = try RelativeDateAmount(
      text: match.string(from: text, atRangeIndex: 2), language: language)
    let unit = try RelativeDateUnit(
      text: match.string(from: text, atRangeIndex: 3), language: language)
    try result.applyOffset(amount: amount, unit: unit, direction: .past)
    return result
  }
}
