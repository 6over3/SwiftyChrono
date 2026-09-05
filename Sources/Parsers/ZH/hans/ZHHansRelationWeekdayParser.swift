//
//  ZHHansRelationWeekdayParser.swift
//  SwiftyChrono
//
//  Ported from chrono.js src/locales/zh/hans/parsers/ZHHansRelationWeekdayParser.ts
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
    "(上|下|这)" +
    "(?:个)?" +
    "(?:星期|礼拜|周)" +
    "(\(ZH_WEEKDAY_OFFSET_PATTERN))"

private let prefixGroup = 1
private let weekdayGroup = 2

public class ZHHansRelationWeekdayParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .chineseSimplified }

    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndexForCHHant(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)

        let dayOfWeek = try match.string(from: text, atRangeIndex: weekdayGroup)
        guard let offset = ZH_WEEKDAY_OFFSET[dayOfWeek] else {
            return nil
        }

        var modifier = ""
        let prefix = try match.string(from: text, atRangeIndex: prefixGroup)

        if prefix == "上" {
            modifier = "last"
        } else if prefix == "下" {
            modifier = "next"
        } else if prefix == "这" {
            modifier = "this"
        }

        result = try updateParsedComponent(result: result, ref: ref, offset: offset, modifier: modifier)
        result.tags[.zhHansRelationWeekdayParser] = true
        return result
    }
}
