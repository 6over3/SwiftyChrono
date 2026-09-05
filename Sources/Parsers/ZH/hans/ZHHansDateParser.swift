//
//  ZHHansDateParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/18/17.
//  Copyright © 2017 Potix. All rights reserved.
//
//  Ported from chrono.js src/locales/zh/hans/parsers/ZHHansDateParser.ts

import Foundation

private let PATTERN =
    "(" +
        "\\d{2,4}|" +
        "\(ZH_HANS_NUMBER_PATTERN){4}|" +
        "\(ZH_HANS_NUMBER_PATTERN){2}" +
    ")?" +
    "(?:\\s*)" +
    "(?:年)?" +
    "(?:[\\s|,|，]*)" +
    "(" +
        "\\d{1,2}|" +
        "\(ZH_HANS_NUMBER_PATTERN){1,3}" +
    ")" +
    "(?:\\s*)" +
    "(?:月)" +
    "(?:\\s*)" +
    "(" +
        "\\d{1,2}|" +
        "\(ZH_HANS_NUMBER_PATTERN){1,3}" +
    ")?" +
    "(?:\\s*)" +
    "(?:日|号)?"

private let yearGroup = 1
private let monthGroup = 2
private let dayGroup = 3

public class ZHHansDateParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .chineseSimplified }

    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndexForCHHant(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)

        let startMoment = ref

        //Month
        let monthString = try match.string(from: text, atRangeIndex: monthGroup)
        let month = Int(monthString) ?? ZHStringToNumber(text: monthString, map: ZH_HANS_NUMBER)
        result.start.assign(.month, value: month)

        //Day
        if match.isNotEmpty(atRangeIndex: dayGroup) {
            let dayString = try match.string(from: text, atRangeIndex: dayGroup)
            let day = Int(dayString) ?? ZHStringToNumber(text: dayString, map: ZH_HANS_NUMBER)
            result.start.assign(.day, value: day)
        } else {
            result.start.imply(.day, to: startMoment.day)
        }

        //Year
        if match.isNotEmpty(atRangeIndex: yearGroup) {
            let yearString = try match.string(from: text, atRangeIndex: yearGroup)
            let year = Int(yearString) ?? ZHStringToYear(text: yearString, map: ZH_HANS_NUMBER)
            result.start.assign(.year, value: year)
        } else {
            result.start.imply(.year, to: startMoment.year)
        }

        result.tags[.zhHansDateParser] = true
        return result
    }
}
