//
//  ZHHansWeekdayParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/18/17.
//  Copyright © 2017 Potix. All rights reserved.
//
//  Ported from chrono.js src/locales/zh/hans/parsers/ZHHansWeekdayParser.ts

import Foundation

private let PATTERN =
    "(?:星期|礼拜|周)" +
    "(\(ZH_WEEKDAY_OFFSET_PATTERN))"

private let weekdayGroup = 1

public class ZHHansWeekdayParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .chineseSimplified }

    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType: Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndexForCHHant(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)

        let dayOfWeek = match.string(from: text, atRangeIndex: weekdayGroup)
        guard let offset = ZH_WEEKDAY_OFFSET[dayOfWeek] else {
            return nil
        }

        result = updateParsedComponent(result: result, ref: ref, offset: offset, modifier: "")
        result.tags[.zhHansWeekdayParser] = true
        return result
    }
}
