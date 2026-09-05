//
//  FRDeadlineFormatParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/6/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "(\\W|^)" +
    "(dans|en)\\s*" +
    "(\(FR_INTEGER_WORDS_PATTERN)|[0-9]+|une?|(?:\\s*quelques)?|demi(?:\\s*|-?)?)\\s*" +
    "(secondes?|min(?:ute)?s?|heures?|jours?|semaines?|mois|années?)\\s*" +
    "(?=\\W|$)"

private let STRICT_PATTERN = "(\\W|^)" +
    "(dans|en)\\s*" +
    "(\(FR_INTEGER_WORDS_PATTERN)|[0-9]+|un?)\\s*" +
    "(secondes?|minutes?|heures?|jours?)\\s*" +
    "(?=\\W|$)"



public class FRDeadlineFormatParser: Parser {
    override var pattern: String { return strictMode ? STRICT_PATTERN : PATTERN }
    override var language: Language { return .french }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        result.tags[.frDeadlineFormatParser] = true
        
        let number: Int
        let numberText = try match.string(from: text, atRangeIndex: 3).lowercased()
        if let number0 = FR_INTEGER_WORDS[numberText] {
            number = number0
        } else if numberText == "un" || numberText == "une" {
            number = 1
        } else if try NSRegularExpression.isMatch(forPattern: "quelques?", in: numberText) {
            number = 3
        } else if try NSRegularExpression.isMatch(forPattern: "demi-?", in: numberText) {
            number = HALF
        } else {
            number = Int(numberText)!
        }
        
        var date = ref
        let matchText4 = try match.string(from: text, atRangeIndex: 4)
        func ymdResult() -> ParsedResult {
            result.start.assign(.year, value: date.year)
            result.start.assign(.month, value: date.month)
            result.start.assign(.day, value: date.day)
            return result
        }
        if try NSRegularExpression.isMatch(forPattern: "jour", in: matchText4) {
            date = number != HALF ? try date.added(number, .day) : try date.added(12, .hour)
            return ymdResult()
        } else if try NSRegularExpression.isMatch(forPattern: "semaine", in: matchText4) {
            date = number != HALF ? try date.added(number * 7, .day) : try date.added(3, .day).added(12, .hour)
            return ymdResult()
        } else if try NSRegularExpression.isMatch(forPattern: "mois", in: matchText4) {
            date = number != HALF ? try date.added(number, .month) : try date.added((date.numberOf(.day, inA: .month) ?? 30)/2, .day)
            return ymdResult()
        } else if try NSRegularExpression.isMatch(forPattern: "année", in: matchText4) {
            date = number != HALF ? try date.added(number, .year) : try date.added(6, .month)
            return ymdResult()
        }
        
        
        
        if try NSRegularExpression.isMatch(forPattern: "heure", in: matchText4) {
            date = number != HALF ? try date.added(number, .hour) : try date.added(30, .minute)
        } else if try NSRegularExpression.isMatch(forPattern: "min", in: matchText4) {
            date = number != HALF ? try date.added(number, .minute) : try date.added(30, .second)
        } else if try NSRegularExpression.isMatch(forPattern: "secondes", in: matchText4) {
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
