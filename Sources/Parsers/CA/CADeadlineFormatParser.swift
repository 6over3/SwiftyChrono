//
//  CADeadlineFormatParser.swift
//  SwiftyChrono
//
//  Translated from ESDeadlineFormatParser.swift.
//  Original work Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\W|^)(d'aquí|dins\\s*de|dintre\\s*de|dins\\s*d'|dintre\\s*d'|en)\\s*([0-9]+|mig|mitja|una?)\\s*(minuts?|hores|hora|dies|dia)\\s*(?=(?:\\W|$))"

public class CADeadlineFormatParser: Parser {
  override var pattern: String { return PATTERN }
  override var language: Language { return .catalan }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: matchText)
    result.tags[.caDeadlineFormatParser] = true
    let amount = try RelativeDateAmount(
      text: match.string(from: text, atRangeIndex: 3), language: language)
    let unit = try RelativeDateUnit(
      text: match.string(from: text, atRangeIndex: 4), language: language)
    try result.applyOffset(amount: amount, unit: unit, direction: .future)
    return result
  }
}
