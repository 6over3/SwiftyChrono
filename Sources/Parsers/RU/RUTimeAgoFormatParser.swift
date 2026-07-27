//
//  RUTimeAgoFormatParser.swift
//  SwiftyChrono
//
//  Created by Nickolay Truhin on 06.04.2021.
//

import Foundation

// RU_TIME_UNIT_PATTERN/RU_TIME_UNIT_STRICT_PATTERN already carry the number and unit as
// their own two capture groups (mirroring ENTimeAgoFormatParser's PATTERN/STRICT_PATTERN),
// so they are spliced in directly rather than wrapped in another capturing group — an
// extra wrap would shift "number"/"unit" to groups 3/4 in casual mode while leaving them
// at 2/3 in strict mode, since the two patterns aren't structured identically.
private let PATTERN = "(\\W|^)" +
    "(?:в течении\\s*)?" +
    RU_TIME_UNIT_PATTERN +
    "(?:назад|ранее)(?=(?:\\W|$))"

private let STRICT_PATTERN = "(\\W|^)" +
    "(?:в течении\\s*)?" +
    RU_TIME_UNIT_STRICT_PATTERN +
    "назад(?=(?:\\W|$))"

public class RUTimeAgoFormatParser: Parser {
    override var pattern: String { strictMode ? STRICT_PATTERN : PATTERN }
    override var language: Language { .russian }
    
    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType: Int]) -> ParsedResult? {
        let idx = match.range(at: 0).location
        if idx > 0 && NSRegularExpression.isMatch(forPattern: "\\w", in: text.substring(from: idx - 1, to: idx)) {
            return nil
        }
        
        let (matchText, index) = matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        let number: Int
        let numberText = match.string(from: text, atRangeIndex: 2).lowercased()
        if let number0 = RU_INTEGER_WORDS[numberText] {
            number = number0
        } else if NSRegularExpression.isMatch(forPattern: "несколько", in: numberText) {
            number = 3
        } else if NSRegularExpression.isMatch(forPattern: "пол", in: numberText) {
            number = HALF
        } else if let num = Int(numberText) {
            number = num
        } else {
            number = 1
        }

        var date = ref
        let matchText3 = match.string(from: text, atRangeIndex: 3)
        func ymdResult() -> ParsedResult {
            result.start.imply(.day, to: date.day)
            result.start.imply(.month, to: date.month)
            result.start.imply(.year, to: date.year)
            result.start.assign(.hour, value: date.hour)
            result.start.assign(.minute, value: date.minute)
            result.start.assign(.second, value: date.second)
            result.tags[.ruTimeAgoFormatParser] = true
            return result
        }
        if NSRegularExpression.isMatch(forPattern: "час", in: matchText3) {
            date = number != HALF ? date.added(-number, .hour) : date.added(-30, .minute)
            return ymdResult()
        } else if NSRegularExpression.isMatch(forPattern: "минут", in: matchText3) {
            date = number != HALF ? date.added(-number, .minute) : date.added(-30, .second)
            return ymdResult()
        } else if NSRegularExpression.isMatch(forPattern: "секунд", in: matchText3) {
            date = number != HALF ? date.added(-number, .second) : date.added(-HALF_SECOND_IN_MS, .nanosecond)
            return ymdResult()
        }

        if NSRegularExpression.isMatch(forPattern: "недел", in: matchText3) {
            date = number != HALF ? date.added(-number * 7, .day) : date.added(-3, .day).added(-12, .hour)

            result.start.imply(.day, to: date.day)
            result.start.imply(.month, to: date.month)
            result.start.imply(.year, to: date.year)
            result.start.imply(.weekday, to: date.weekday)
            result.tags[.ruTimeAgoFormatParser] = true
            return result
        } else if NSRegularExpression.isMatch(forPattern: "дн", in: matchText3) {
            date = number != HALF ? date.added(-number, .day) : date.added(-12, .hour)
        } else if NSRegularExpression.isMatch(forPattern: "месяц", in: matchText3) {
            date = number != HALF ? date.added(-number, .month) : date.added(-(date.numberOf(.day, inA: .month) ?? 30)/2, .day)
        } else if NSRegularExpression.isMatch(forPattern: "год|лет", in: matchText3) {
            date = number != HALF ? date.added(-number, .year) : date.added(-6, .month)
        }
        
        result.start.assign(.day, value: date.day)
        result.start.assign(.month, value: date.month)
        result.start.assign(.year, value: date.year)
        result.tags[.ruTimeAgoFormatParser] = true
        return result
    }
}
