//
//  ESDeadlineFormatParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/6/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\W|^)(dentro\\s+de|en)\\s*"
  + "(\(ES_INTEGER_WORDS_PATTERN)|[+-]?[0-9]+(?:[.,][0-9]+)?|medi[oa]|una?)\\s*"
  + "(segundos?|minutos?|horas?|d[ií]as?|semanas?|mes(?:es)?|años?)\\s*(?=\\W|$)"

public class ESDeadlineFormatParser: Parser {
  override var pattern: String { return PATTERN }
  override var language: Language { return .spanish }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: matchText)
    result.tags[.esDeadlineFormatParser] = true
    let amount = try RelativeDateAmount(
      text: match.string(from: text, atRangeIndex: 3), language: language)
    let unit = try RelativeDateUnit(
      text: match.string(from: text, atRangeIndex: 4), language: language)
    try result.applyOffset(amount: amount, unit: unit, direction: .future)
    if try match.string(from: text, atRangeIndex: 2).lowercased() == "en" {
      result.ambiguities.insert(.durationOrOffset)
    }
    return result
  }
}
