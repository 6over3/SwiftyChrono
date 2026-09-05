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
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let idx = match.range(at: 0).location
        if let str = try text.character(beforeUTF16Offset: idx),
            try NSRegularExpression.isMatch(forPattern: "\\w", in: str) {
            return nil
        }
        
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        let number: Int
        let numberText = try match.string(from: text, atRangeIndex: 2).lowercased()
        if let number0 = RU_INTEGER_WORDS[numberText] {
            number = number0
        } else if try NSRegularExpression.isMatch(forPattern: "несколько", in: numberText) {
            number = 3
        } else if try NSRegularExpression.isMatch(forPattern: "пол", in: numberText) {
            number = HALF
        } else if let num = Int(numberText) {
            number = num
        } else {
            number = 1
        }

        var date = ref
        let matchText3 = try match.string(from: text, atRangeIndex: 3)
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
        if try NSRegularExpression.isMatch(forPattern: "час", in: matchText3) {
            date = number != HALF ? try date.added(-number, .hour) : try date.added(-30, .minute)
            return ymdResult()
        } else if try NSRegularExpression.isMatch(forPattern: "минут", in: matchText3) {
            date = number != HALF ? try date.added(-number, .minute) : try date.added(-30, .second)
            return ymdResult()
        } else if try NSRegularExpression.isMatch(forPattern: "секунд", in: matchText3) {
            date = number != HALF ? try date.added(-number, .second) : try date.added(-HALF_SECOND_IN_MS, .nanosecond)
            return ymdResult()
        }

        if try NSRegularExpression.isMatch(forPattern: "недел", in: matchText3) {
            date = number != HALF ? try date.added(-number * 7, .day) : try date.added(-3, .day).added(-12, .hour)

            result.start.imply(.day, to: date.day)
            result.start.imply(.month, to: date.month)
            result.start.imply(.year, to: date.year)
            result.start.imply(.weekday, to: date.weekday)
            result.tags[.ruTimeAgoFormatParser] = true
            return result
        } else if try NSRegularExpression.isMatch(forPattern: "дн", in: matchText3) {
            date = number != HALF ? try date.added(-number, .day) : try date.added(-12, .hour)
        } else if try NSRegularExpression.isMatch(forPattern: "месяц", in: matchText3) {
            date = number != HALF ? try date.added(-number, .month) : try date.added(-(date.numberOf(.day, inA: .month) ?? 30)/2, .day)
        } else if try NSRegularExpression.isMatch(forPattern: "год|лет", in: matchText3) {
            date = number != HALF ? try date.added(-number, .year) : try date.added(-6, .month)
        }
        
        result.start.assign(.day, value: date.day)
        result.start.assign(.month, value: date.month)
        result.start.assign(.year, value: date.year)
        result.tags[.ruTimeAgoFormatParser] = true
        return result
    }
}
