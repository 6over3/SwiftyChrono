//
//  DEDeadlineFormatParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/8/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\W|^)" + "(innerhalb|in|im)\\s*(?:von)?\\s*"
  + "(\(DE_INTEGER_WORDS_PATTERN)|[0-9]+|\(DE_INTEGER1_WORDS_PATTERN)?(?:\\s*(?:wenige[r|n]?|einigen?|paar))?|(?:\(DE_INTEGER1_WORDS_PATTERN)\\s*)?halbe(?:n|s)?)\\s*"
  + "(sekunden?|minuten?|stunden?|tag(?:en|e)?|wochen?|monat(?:en|e|s)?|jahr(?:en|(?:es)|e)??)\\s*"
  + "(?=\\W|$)"

public class DEDeadlineFormatParser: Parser {
  override var pattern: String { return PATTERN }
  override var language: Language { return .german }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: matchText)
    result.tags[.deDeadlineFormatParser] = true
    let amount = try RelativeDateAmount(
      text: match.string(from: text, atRangeIndex: 3), language: language)
    let unit = try RelativeDateUnit(
      text: match.string(from: text, atRangeIndex: 4), language: language)
    let relation = try match.string(from: text, atRangeIndex: 2).lowercased()
    if relation == "innerhalb" {
      try result.applyRollingRange(amount: amount, unit: unit, direction: .future)
    } else {
      try result.applyOffset(amount: amount, unit: unit, direction: .future)
    }
    return result
  }
}
