//
//  ZHHantWeekdayParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/18/17.
//  Copyright © 2017 Potix. All rights reserved.
//
//  Ported from chrono.js src/locales/zh/hant/parsers/ZHHantWeekdayParser.ts

import Foundation

private let PATTERN =
    "(?:星期|禮拜|週)" +
    "(\(ZH_WEEKDAY_OFFSET_PATTERN))"

private let weekdayGroup = 1

public class ZHHantWeekdayParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .chinese }

    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndexForCHHant(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)

        let dayOfWeek = try match.string(from: text, atRangeIndex: weekdayGroup)
        guard let offset = ZH_WEEKDAY_OFFSET[dayOfWeek] else {
            return nil
        }

        result = try updateParsedComponent(result: result, ref: ref, offset: offset, modifier: "")
        result.tags[.zhHantWeekdayParser] = true
        return result
    }
}
