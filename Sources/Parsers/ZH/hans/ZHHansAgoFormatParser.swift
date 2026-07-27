//
//  ZHHansAgoFormatParser.swift
//  SwiftyChrono
//
//  Ported from chrono.js src/locales/zh/hans/parsers/ZHHansAgoFormatParser.ts
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
    "(\\d+|\(ZH_HANS_NUMBER_PATTERN)+|半|几)(?:\\s*)" +
    "(?:个)?" +
    "(秒(?:钟)?|分钟|小时|钟|日|天|星期|礼拜|月|年)" +
    "(?:之)?前"

private let numberGroup = 1
private let unitGroup = 2

public class ZHHansAgoFormatParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .chineseSimplified }

    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType: Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndexForCHHant(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        result.tags[.zhHansAgoFormatParser] = true

        let numberString = match.string(from: text, atRangeIndex: numberGroup)
        let number: Int
        if numberString == "几" {
            number = 3
        } else if numberString == "半" {
            number = HALF
        } else if let intValue = Int(numberString) {
            number = intValue
        } else {
            number = ZHStringToNumber(text: numberString, map: ZH_HANS_NUMBER)
        }

        var date = ref
        let unit = match.string(from: text, atRangeIndex: unitGroup)
        let unitAbbr = unit.firstString ?? ""

        func ymdResult() -> ParsedResult {
            result.start.assign(.year, value: date.year)
            result.start.assign(.month, value: date.month)
            result.start.assign(.day, value: date.day)
            return result
        }

        if unitAbbr == "日" || unitAbbr == "天" {
            date = number == HALF ? date.added(-12, .hour) : date.added(-number, .day)
            return ymdResult()
        } else if unitAbbr == "星" || unitAbbr == "礼" {
            date = number == HALF ? date.added(-3, .day).added(-12, .hour) : date.added(-number * 7, .day)
            return ymdResult()
        } else if unitAbbr == "月" {
            date = number == HALF ? date.added(-((date.numberOf(.day, inA: .month) ?? 30) / 2), .day) : date.added(-number, .month)
            return ymdResult()
        } else if unitAbbr == "年" {
            date = number == HALF ? date.added(-6, .month) : date.added(-number, .year)
            return ymdResult()
        }

        if unitAbbr == "秒" {
            date = number == HALF ? date.added(-HALF_SECOND_IN_MS, .nanosecond) : date.added(-number, .second)
        } else if unitAbbr == "分" {
            date = number == HALF ? date.added(-30, .second) : date.added(-number, .minute)
        } else if unitAbbr == "小" || unitAbbr == "钟" {
            date = number == HALF ? date.added(-30, .minute) : date.added(-number, .hour)
        }

        result.start.imply(.year, to: date.year)
        result.start.imply(.month, to: date.month)
        result.start.imply(.day, to: date.day)
        result.start.assign(.hour, value: date.hour)
        result.start.assign(.minute, value: date.minute)
        result.start.assign(.second, value: date.second)

        return result
    }
}
