//
//  ZHHantDeadlineFormatParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/18/17.
//  Copyright © 2017 Potix. All rights reserved.
//
//  Ported from chrono.js src/locales/zh/hant/parsers/ZHHantDeadlineFormatParser.ts

import Foundation

private let PATTERN =
  "(\\d+|\(ZH_HANT_NUMBER_PATTERN)+|半|幾)(?:\\s*)" + "(?:個)?" + "(秒(?:鐘)?|分鐘|小時|鐘|日|天|星期|禮拜|月|年)"
  + "((?:之|過)?後|(?:之)?內)"

public class ZHHantDeadlineFormatParser: Parser {
  override var pattern: String { return PATTERN }
  override var language: Language { return .chinese }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (matchText, index) = try matchTextAndIndexForCHHant(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: matchText)
    result.tags[.zhHantDeadlineFormatParser] = true
    let amount = try RelativeDateAmount(
      text: match.string(from: text, atRangeIndex: 1), language: language)
    let unit = try RelativeDateUnit(
      text: match.string(from: text, atRangeIndex: 2), language: language)
    let relation = try match.string(from: text, atRangeIndex: 3)
    if relation.hasSuffix("內") {
      try result.applyRollingRange(amount: amount, unit: unit, direction: .future)
    } else {
      try result.applyOffset(amount: amount, unit: unit, direction: .future)
    }
    return result
  }
}
