//
//  CATimeAgoFormatParser.swift
//  SwiftyChrono
//
//  Translated from ESTimeAgoFormatParser.swift.
//  Original work Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\W|^)fa\\s*([0-9]+|mig|mitja|una?)\\s*(minuts?|hores|hora|setmanes|setmana|dies|dia|mes(os)?|anys?)(?=(?:\\W|$))"

public class CATimeAgoFormatParser: Parser {
  override var pattern: String { return PATTERN }
  override var language: Language { return .catalan }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: matchText)
    result.tags[.caTimeAgoFormatParser] = true
    let amount = try RelativeDateAmount(
      text: match.string(from: text, atRangeIndex: 2), language: language)
    let unit = try RelativeDateUnit(
      text: match.string(from: text, atRangeIndex: 3), language: language)
    try result.applyOffset(amount: amount, unit: unit, direction: .past)
    return result
  }
}
