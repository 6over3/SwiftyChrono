//
//  ZHHansCasualDateParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/18/17.
//  Copyright © 2017 Potix. All rights reserved.
//
//  Ported from chrono.js src/locales/zh/hans/parsers/ZHHansCasualDateParser.ts

import Foundation

private let PATTERN =
    "(现在|立(?:刻|即)|即刻)|" +
    "(今|明|前|大前|后|大后|昨)(早|晚)|" +
    "(上(?:午)|早(?:上)|下(?:午)|晚(?:上)|夜(?:晚)?|中(?:午)|凌(?:晨))|" +
    "(今|明|前|大前|后|大后|昨)(?:日|天)" +
    "(?:[\\s|,|，]*)" +
    "(?:(上(?:午)|早(?:上)|下(?:午)|晚(?:上)|夜(?:晚)?|中(?:午)|凌(?:晨)))?"

private let nowGroup = 1
private let dayGroup1 = 2
private let timeGroup1 = 3
private let timeGroup2 = 4
private let dayGroup3 = 5
private let timeGroup3 = 6

public class ZHHansCasualDateParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .chineseSimplified }

    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndexForCHHant(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)

        let refMoment = ref
        var startMoment = refMoment

        if match.isNotEmpty(atRangeIndex: nowGroup) {
            result.start.imply(.hour, to: refMoment.hour)
            result.start.imply(.minute, to: refMoment.minute)
            result.start.imply(.second, to: refMoment.second)
            result.start.imply(.millisecond, to: refMoment.millisecond)
        } else if match.isNotEmpty(atRangeIndex: dayGroup1) {
            let day1 = try match.string(from: text, atRangeIndex: dayGroup1)
            let time1 = try match.string(from: text, atRangeIndex: timeGroup1)

            if day1 == "明" {
                // Check not "Tomorrow" on late night
                if refMoment.hour > 1 {
                    startMoment = try startMoment.added(1, .day)
                }
            } else if day1 == "昨" {
                startMoment = try startMoment.added(-1, .day)
            } else if day1 == "前" {
                startMoment = try startMoment.added(-2, .day)
            } else if day1 == "大前" {
                startMoment = try startMoment.added(-3, .day)
            } else if day1 == "后" {
                startMoment = try startMoment.added(2, .day)
            } else if day1 == "大后" {
                startMoment = try startMoment.added(3, .day)
            }

            if time1 == "早" {
                result.start.imply(.hour, to: 6)
            } else if time1 == "晚" {
                result.start.imply(.hour, to: 22)
                result.start.imply(.meridiem, to: 1)
            }

        } else if match.isNotEmpty(atRangeIndex: timeGroup2) {
            let timeString2 = try match.string(from: text, atRangeIndex: timeGroup2)
            let time2 = timeString2.firstString ?? ""

            if time2 == "早" || time2 == "上" {
                result.start.imply(.hour, to: 6)
            } else if time2 == "下" {
                result.start.imply(.hour, to: 15)
                result.start.imply(.meridiem, to: 1)
            } else if time2 == "中" {
                result.start.imply(.hour, to: 12)
                result.start.imply(.meridiem, to: 1)
            } else if time2 == "夜" || time2 == "晚" {
                result.start.imply(.hour, to: 22)
                result.start.imply(.meridiem, to: 1)
            } else if time2 == "凌" {
                result.start.imply(.hour, to: 0)
            }

        } else if match.isNotEmpty(atRangeIndex: dayGroup3) {
            let day3 = try match.string(from: text, atRangeIndex: dayGroup3)

            if day3 == "明" {
                // Check not "Tomorrow" on late night
                if refMoment.hour > 1 {
                    startMoment = try startMoment.added(1, .day)
                }
            } else if day3 == "昨" {
                startMoment = try startMoment.added(-1, .day)
            } else if day3 == "前" {
                startMoment = try startMoment.added(-2, .day)
            } else if day3 == "大前" {
                startMoment = try startMoment.added(-3, .day)
            } else if day3 == "后" {
                startMoment = try startMoment.added(2, .day)
            } else if day3 == "大后" {
                startMoment = try startMoment.added(3, .day)
            }

            if match.isNotEmpty(atRangeIndex: timeGroup3) {
                let timeString3 = try match.string(from: text, atRangeIndex: timeGroup3)
                let time3 = timeString3.firstString ?? ""

                if time3 == "早" || time3 == "上" {
                    result.start.imply(.hour, to: 6)
                } else if time3 == "下" {
                    result.start.imply(.hour, to: 15)
                    result.start.imply(.meridiem, to: 1)
                } else if time3 == "中" {
                    result.start.imply(.hour, to: 12)
                    result.start.imply(.meridiem, to: 1)
                } else if time3 == "夜" || time3 == "晚" {
                    result.start.imply(.hour, to: 22)
                    result.start.imply(.meridiem, to: 1)
                } else if time3 == "凌" {
                    result.start.imply(.hour, to: 0)
                }
            }
        }

        result.start.assign(.day, value: startMoment.day)
        result.start.assign(.month, value: startMoment.month)
        result.start.assign(.year, value: startMoment.year)
        result.tags[.zhHansCasualDateParser] = true
        return result
    }
}
