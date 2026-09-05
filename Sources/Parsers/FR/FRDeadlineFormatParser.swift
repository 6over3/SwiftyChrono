//
//  FRDeadlineFormatParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/6/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\W|^)" + "(dans|en)\\s*"
  + "(\(FR_INTEGER_WORDS_PATTERN)|[0-9]+|une?|(?:\\s*quelques)?|demi(?:\\s*|-?)?)\\s*"
  + "(secondes?|min(?:ute)?s?|heures?|jours?|semaines?|mois|années?)\\s*" + "(?=\\W|$)"

private let STRICT_PATTERN =
  "(\\W|^)" + "(dans|en)\\s*" + "(\(FR_INTEGER_WORDS_PATTERN)|[0-9]+|un?)\\s*"
  + "(secondes?|minutes?|heures?|jours?)\\s*" + "(?=\\W|$)"

public class FRDeadlineFormatParser: Parser {
  override var pattern: String { return strictMode ? STRICT_PATTERN : PATTERN }
  override var language: Language { return .french }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: matchText)
    result.tags[.frDeadlineFormatParser] = true
    let amount = try RelativeDateAmount(
      text: match.string(from: text, atRangeIndex: 3), language: language)
    let unit = try RelativeDateUnit(
      text: match.string(from: text, atRangeIndex: 4), language: language)
    try result.applyOffset(amount: amount, unit: unit, direction: .future)
    return result
  }
}
