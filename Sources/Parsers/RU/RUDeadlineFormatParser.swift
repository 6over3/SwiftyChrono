//
//  RUDeadlineDateParser.swift
//  SwiftyChrono
//
//  Created by Nickolay Truhin on 06.04.2021.
//

import Foundation

private let PATTERN = "(\\W|^)" +
    "(через|спустя)\\s*" +
    "(" + RU_INTEGER_WORDS_PATTERN + "|[0-9]+|несколько|одну|один\\s*пол|одну)?\\s*" +
    "((секунда|секунд|секунды|секунду)|(минут|минуту|минуты)|(часов|час|часа)|(дней|день|дня)|(недель|неделю|неделя|недели)|(месяцев|месяц|месяца)|(лет|год|года))\\s*" +
    "(?=\\W|$)"



private let STRICT_PATTERN = "(\\W|^)" +
    "(через|спустя)\\s*" +
    "(" + RU_INTEGER_WORDS_PATTERN + "|[0-9]+|одну(?:r|m)?)\\s*" +
    "((секунд|секунду|секунды)|(минут|минуту|минуты)|(часов|часа|час)|(дней|день|дня))\\s*" +
    "(?=\\W|$)"



public class RUDeadlineFormatParser: Parser {
    override var pattern: String { strictMode ? STRICT_PATTERN : PATTERN }
    override var language: Language { .russian }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        result.tags[.ruDeadlineFormatParser] = true
        
        let number: Int
        let numberText = try match.string(from: text, atRangeIndex: 3).lowercased()
        if let number0 = RU_INTEGER_WORDS[numberText] {
            number = number0
        } else if numberText == "один" || numberText == "одну" {
            number = 1
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
        let matchText4 = try match.string(from: text, atRangeIndex: 4)
        func ymdResult() -> ParsedResult {
            result.start.assign(.year, value: date.year)
            result.start.assign(.month, value: date.month)
            result.start.assign(.day, value: date.day)
            return result
        }
        if try NSRegularExpression.isMatch(forPattern: "день|дня|дней", in: matchText4) {
            date = number != HALF ? try date.added(number, .day) : try date.added(12, .hour)
            return ymdResult()
        } else if try NSRegularExpression.isMatch(forPattern: "недель|неделю|неделя|недели", in: matchText4) {
            date = number != HALF ? try date.added(number * 7, .day) : try date.added(3, .day).added(12, .hour)
            return ymdResult()
        } else if try NSRegularExpression.isMatch(forPattern: "месяц|месяцев|месяца", in: matchText4) {
            date = number != HALF ? try date.added(number, .month) : try date.added((date.numberOf(.day, inA: .month) ?? 30)/2, .day)
            return ymdResult()
        } else if try NSRegularExpression.isMatch(forPattern: "год|года|лет", in: matchText4) {
            date = number != HALF ? try date.added(number, .year) : try date.added(6, .month)
            return ymdResult()
        }
        
        
        
        if try NSRegularExpression.isMatch(forPattern: "часов|час|часа", in: matchText4) {
            date = number != HALF ? try date.added(number, .hour) : try date.added(30, .minute)
        } else if try NSRegularExpression.isMatch(forPattern: "минут|минуту|минуты", in: matchText4) {
            date = number != HALF ? try date.added(number, .minute) : try date.added(30, .second)
        } else if try NSRegularExpression.isMatch(forPattern: "секунд|секунду|секунды", in: matchText4) {
            date = number != HALF ? try date.added(number, .second) : try date.added(HALF_SECOND_IN_MS, .nanosecond)
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
