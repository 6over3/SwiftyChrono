//
//  ENDeadlineFormatParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/19/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\W|^)" + "(within|in)\\s*"
  + "(\(EN_INTEGER_WORDS_PATTERN)|[0-9]+|an?(?:\\s*few)?|half(?:\\s*an?)?)\\s*"
  + "(seconds?|min(?:ute)?s?|hours?|days?|weeks?|months?|years?)\\s*" + "(?=\\W|$)"

private let STRICT_PATTERN =
  "(\\W|^)" + "(within|in)\\s*" + "(\(EN_INTEGER_WORDS_PATTERN)|[0-9]+|an?)\\s*"
  + "(seconds?|minutes?|hours?|days?)\\s*" + "(?=\\W|$)"

public class ENDeadlineFormatParser: Parser {
  override var pattern: String { return strictMode ? STRICT_PATTERN : PATTERN }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: matchText)
    result.tags[.enDeadlineFormatParser] = true
    let amount = try RelativeDateAmount(
      text: match.string(from: text, atRangeIndex: 3), language: language)
    let unit = try RelativeDateUnit(
      text: match.string(from: text, atRangeIndex: 4), language: language)
    try result.applyOffset(amount: amount, unit: unit, direction: .future)
    return result
  }
}
