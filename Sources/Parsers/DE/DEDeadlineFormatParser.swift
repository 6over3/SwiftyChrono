//
//  DEDeadlineFormatParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/8/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "(\\W|^)" +
    "(innerhalb|i[n|m])\\s*(?:von)?\\s*" +
    "(\(DE_INTEGER_WORDS_PATTERN)|[0-9]+|\(DE_INTEGER1_WORDS_PATTERN)?(?:\\s*(?:wenige[r|n]?|einigen?|paar))?|(?:\(DE_INTEGER1_WORDS_PATTERN)\\s*)?halbe(?:n|s)?)\\s*" +
    "(sekunden?|minuten?|stunden?|tag(?:en|e)?|wochen?|monat(?:en|e|s)?|jahr(?:en|(?:es)|e)??)\\s*" +
    "(?=\\W|$)"



public class DEDeadlineFormatParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .german }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        result.tags[.deDeadlineFormatParser] = true
        
        let number: Int
        let numberText = try match.string(from: text, atRangeIndex: 3).lowercased()
        if let number0 = DE_INTEGER_WORDS[numberText] {
            number = number0
        } else if DE_INTEGER1_WORDS[numberText] != nil {
            number = 1
        } else if try NSRegularExpression.isMatch(forPattern: "wenige|einige|paar", in: numberText) {
            number = 3
        } else if try NSRegularExpression.isMatch(forPattern: "halbe", in: numberText) {
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
        if try NSRegularExpression.isMatch(forPattern: "tag", in: matchText4) {
            date = number != HALF ? try date.added(number, .day) : try date.added(12, .hour)
            return ymdResult()
        } else if try NSRegularExpression.isMatch(forPattern: "woche", in: matchText4) {
            date = number != HALF ? try date.added(number * 7, .day) : try date.added(3, .day).added(12, .hour)
            return ymdResult()
        } else if try NSRegularExpression.isMatch(forPattern: "monat", in: matchText4) {
            date = number != HALF ? try date.added(number, .month) : try date.added((date.numberOf(.day, inA: .month) ?? 30)/2, .day)
            return ymdResult()
        } else if try NSRegularExpression.isMatch(forPattern: "jahr", in: matchText4) {
            date = number != HALF ? try date.added(number, .year) : try date.added(6, .month)
            return ymdResult()
        }
        
        
        
        if try NSRegularExpression.isMatch(forPattern: "stunde", in: matchText4) {
            date = number != HALF ? try date.added(Int(number), .hour) : try date.added(30, .minute)
        } else if try NSRegularExpression.isMatch(forPattern: "minute", in: matchText4) {
            date = number != HALF ? try date.added(Int(number), .minute) : try date.added(30, .second)
        } else if try NSRegularExpression.isMatch(forPattern: "sekunde", in: matchText4) {
            date = number != HALF ? try date.added(Int(number), .second) : try date.added(HALF_SECOND_IN_MS, .nanosecond)
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

