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
    "(\\d+|\(ZH_HANT_NUMBER_PATTERN)+|半|幾)(?:\\s*)" +
    "(?:個)?" +
    "(秒(?:鐘)?|分鐘|小時|鐘|日|天|星期|禮拜|月|年)" +
    "(?:(?:之|過)?後|(?:之)?內)"

private let numberGroup = 1
private let unitGroup = 2

public class ZHHantDeadlineFormatParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .chinese }

    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndexForCHHant(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        result.tags[.zhHantDeadlineFormatParser] = true

        let numberString = try match.string(from: text, atRangeIndex: numberGroup)
        let number: Int
        if numberString == "幾" {
            number = 3
        } else if numberString == "半" {
            number = HALF
        } else if let intValue = Int(numberString) {
            number = intValue
        } else {
            number = ZHStringToNumber(text: numberString, map: ZH_HANT_NUMBER)
        }

        var date = ref
        let unit = try match.string(from: text, atRangeIndex: unitGroup)
        let unitAbbr = unit.firstString ?? ""

        func ymdResult() -> ParsedResult {
            result.start.assign(.year, value: date.year)
            result.start.assign(.month, value: date.month)
            result.start.assign(.day, value: date.day)
            return result
        }

        if unitAbbr == "日" || unitAbbr == "天" {
            date = number == HALF ? try date.added(12, .hour) : try date.added(number, .day)
            return ymdResult()
        } else if unitAbbr == "星" || unitAbbr == "禮" {
            date = number == HALF ? try date.added(3, .day).added(12, .hour) : try date.added(number * 7, .day)
            return ymdResult()
        } else if unitAbbr == "月" {
            date = number == HALF ? try date.added((date.numberOf(.day, inA: .month) ?? 30) / 2, .day) : try date.added(number, .month)
            return ymdResult()
        } else if unitAbbr == "年" {
            date = number == HALF ? try date.added(6, .month) : try date.added(number, .year)
            return ymdResult()
        }

        if unitAbbr == "秒" {
            date = number == HALF ? try date.added(HALF_SECOND_IN_MS, .nanosecond) : try date.added(number, .second)
        } else if unitAbbr == "分" {
            date = number == HALF ? try date.added(30, .second) : try date.added(number, .minute)
        } else if unitAbbr == "小" || unitAbbr == "鐘" {
            date = number == HALF ? try date.added(30, .minute) : try date.added(number, .hour)
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
