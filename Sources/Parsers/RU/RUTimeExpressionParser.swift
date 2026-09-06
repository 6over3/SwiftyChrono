//
//  RUTimeExpressionParser.swift
//  SwiftyChrono
//
//  Created by Nickolay Truhin on 06.04.2021.
//

import Foundation

private let FIRST_REG_PATTERN = "(^|\\s|T)" +
    "(?:в\\s*)?" +
    "(\\d{1,4}|утра|вечера)" +
    "(?:" +
    "(?:\\.|\\:|\\：)(\\d{1,2})" +
    "(?:" +
    "(?:\\:|\\：)(\\d{2})" +
    ")?" +
    ")?" +
    "(?:\\s*uhr)?" +
    "(?:\\s*(утра|вечера|ночи))?" +
    "(?=\\W|$)"

private let SECOND_REG_PATTERN = "^\\s*" +
    "(\\-|\\–|\\~|\\〜|в|\\?)\\s*" +
    "(\\d{1,4})" +
    "(?:" +
    "(?:\\.|\\:|\\：)(\\d{1,2})" +
    "(?:" +
    "(?:\\.|\\:|\\：)(\\d{1,2})" +
    ")?" +
    ")?" +
    "(?:\\s*(утра|вечера|ночи))?" +
    "(?![-/]\\d)(?=\\W|$)"

private let hourGroup = 2
private let minuteGroup = 3
private let secondGroup = 4
private let amPmHourGroup = 5

public class RUTimeExpressionParser: Parser {
    override var pattern: String { FIRST_REG_PATTERN }
    override var language: Language { .russian }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        // This pattern can be overlaped Ex. [12] AM, 1[2] AM
        let idx = match.range(at: 0).location
        if let str = try text.character(beforeUTF16Offset: idx),
            try NSRegularExpression.isMatch(forPattern: "\\w", in: str) {
            return nil
        }
        
        var (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        result.tags[.ruTimeExpressionParser] = true
        
        result.start.imply(.day, to: ref.day)
        result.start.imply(.month, to: ref.month)
        result.start.imply(.year, to: ref.year)
        
        var hour = 0
        var minute = 0
        var meridiem = -1
        
        // ----- Second
        if match.isNotEmpty(atRangeIndex: secondGroup) {
            if let second = try Int(match.string(from: text, atRangeIndex: secondGroup)) {
                if second >= 60 {
                    return nil
                }
                
                result.start.assign(.second, value: second)
            }
        }
        
        // ----- Hours
        let hourText = match.isNotEmpty(atRangeIndex: hourGroup) ? try match.string(from: text, atRangeIndex: hourGroup).lowercased() : ""
        if hourText == "вечера" {
            result.start.dayPeriod = DayPeriod(.evening1, language: language)
            meridiem = 1
            hour = 12
        } else if hourText == "утра" {
            result.start.dayPeriod = DayPeriod(.morning1, language: language)
            meridiem = 0
            hour = 0
        } else if let h = Int(hourText) {
            hour = h
        } else {
            return nil
        }
        
        // ----- Minutes
        if match.isNotEmpty(atRangeIndex: minuteGroup) {
            minute = Int(try match.string(from: text, atRangeIndex: minuteGroup))!
        } else if hour > 100 {
            minute = hour % 100
            hour = hour/100
        }
        
        if minute >= 60 || hour > 24 {
            return nil
        }
        
        if hour >= 12 {
            meridiem = 1
        }
        
        // ----- AM & PM
        if match.isNotEmpty(atRangeIndex: amPmHourGroup) {
            let word = try match.string(from: text, atRangeIndex: amPmHourGroup).lowercased()
            let phase: DayPeriod.Phase
            switch word {
            case "утра": phase = .am
            case "вечера": phase = .pm
            case "ночи": phase = .night1
            default: throw ChronoError.invalidSourceRange
            }
            result.start.dayPeriod = DayPeriod(phase, language: language)
        }

        if Int(hourText) != nil {
            result.start.assign(.hour, value: hour)
            result.start.assign(.minute, value: minute)
        } else {
            result.start.imply(.hour, to: hour)
            result.start.imply(.minute, to: minute)
        }
        if meridiem >= 0 {
            result.start.assign(.meridiem, value: meridiem)
        } else {
            result.start.imply(.meridiem, to: hour < 12 ? 0 : 1)
        }
        
        // ==============================================================
        //                  Extracting the 'to' chunk
        // ==============================================================
        
        let regex = try? NSRegularExpression(pattern: SECOND_REG_PATTERN, options: .caseInsensitive)
        let secondText = try text.substring(from: result.index + result.text.utf16.count)
        guard let match = regex?.firstMatch(in: secondText, range: NSRange(location: 0, length: secondText.utf16.count)) else {
            // Not accept number only result
            if try NSRegularExpression.isMatch(forPattern: "^\\d+$", in: result.text) {
                return try TemporalComparisonGrammar.unresolvedClock(result, in: text, language: language)
            }
            
            return result
        }
        matchText = try match.string(from: secondText, atRangeIndex: 0)
        
        // Pattern "YY.YY -XXXX" is more like timezone offset
        if try NSRegularExpression.isMatch(forPattern: "^\\s*(\\+|\\-)\\s*\\d{3,4}$", in: matchText) {
            return result
        }
        
        if result.end == nil {
            result.end = ParsedComponents(inheritingDateFrom: result.start, ref: ref)
        }
        
        hour = 0
        minute = 0
        meridiem = -1
        
        // ----- Second
        if match.isNotEmpty(atRangeIndex: secondGroup) {
            let second = Int(try match.string(from: secondText, atRangeIndex: secondGroup))!
            if second >= 60 {
                return nil
            }
            
            result.end?.assign(.second, value: second)
        }
        
        hour = Int(try match.string(from: secondText, atRangeIndex: hourGroup))!
        
        // ----- Minute
        if match.isNotEmpty(atRangeIndex: minuteGroup) {
            minute = Int(try match.string(from: secondText, atRangeIndex: minuteGroup))!
            if minute >= 60 {
                return result
            }
        } else if hour > 100 {
            minute = hour % 100
            hour = hour / 100
        }
        
        if minute >= 60 || hour > 24 {
            return nil
        }
        
        if hour >= 12 {
            meridiem = 1
        }
        
        // ----- AM & PM
        if match.isNotEmpty(atRangeIndex: amPmHourGroup) {
            let word = try match.string(from: secondText, atRangeIndex: amPmHourGroup).lowercased()
            let phase: DayPeriod.Phase
            switch word {
            case "утра": phase = .am
            case "вечера": phase = .pm
            case "ночи": phase = .night1
            default: throw ChronoError.invalidSourceRange
            }
            result.end?.dayPeriod = DayPeriod(phase, language: language)
            if !result.start.isCertain(component: .meridiem), result.start.dayPeriod == nil {
                result.start.dayPeriod = DayPeriod(phase, language: language)
            }
        }

        result.text += matchText
        result.end!.assign(.hour, value: hour)
        result.end!.assign(.minute, value: minute)
        if meridiem >= 0 {
            result.end!.assign(.meridiem, value: meridiem)
        } else {
            let startAtPm = result.start.isCertain(component: .meridiem) && result.start[.meridiem]! == 1
            if startAtPm && result.start[.hour]! > hour {
                // 10pm - 1 (am)
                result.end!.imply(.meridiem, to: 0)
            } else if hour > 12 {
                result.end!.imply(.meridiem, to: 1)
            }
        }
        
        result.resolveClockQualifiers()
        guard result.issues.isEmpty else { return result }
        if result.end!.isDefinitelyBefore(result.start) {
                        try result.end?.shiftCalendarDays(1)
        }
        
        return result
    }
}
