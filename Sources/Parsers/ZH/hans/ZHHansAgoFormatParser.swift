//
//  ZHHansAgoFormatParser.swift
//  SwiftyChrono
//
//  Ported from chrono.js src/locales/zh/hans/parsers/ZHHansAgoFormatParser.ts
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\d+|\(ZH_HANS_NUMBER_PATTERN)+|半|几)(?:\\s*)" + "(?:个)?" + "(秒(?:钟)?|分钟|小时|钟|日|天|星期|礼拜|月|年)"
  + "(?:之)?前"

public class ZHHansAgoFormatParser: Parser {
  override var pattern: String { return PATTERN }
  override var language: Language { return .chineseSimplified }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (matchText, index) = try matchTextAndIndexForCHHant(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: matchText)
    result.tags[.zhHansAgoFormatParser] = true
    let amount = try RelativeDateAmount(
      text: match.string(from: text, atRangeIndex: 1), language: language)
    let unit = try RelativeDateUnit(
      text: match.string(from: text, atRangeIndex: 2), language: language)
    try result.applyOffset(amount: amount, unit: unit, direction: .past)
    return result
  }
}
