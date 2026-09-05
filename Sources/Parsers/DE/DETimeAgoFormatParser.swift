//
//  DETimeAgoFormatParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/8/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "(\\W|^)vor\\s*" +
    "(\(DE_INTEGER_WORDS_PATTERN)|[0-9]+|\(DE_INTEGER1_WORDS_PATTERN)?(?:\\s*(?:wenige[r|n]?|einigen?|paar))?|(?:\(DE_INTEGER1_WORDS_PATTERN))?\\s*halbe(?:n|s)?)\\s*" +
    "(sekunden?|minuten?|stunden?|tag(?:en|e)?|wochen?|monat(?:en|e|s)?|jahr(?:en|(?:es)|e)??)(?=(?:\\W|$))"



public class DETimeAgoFormatParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .german }
    
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
        let matchText3 = try match.string(from: text, atRangeIndex: 3)
        func ymdResult() -> ParsedResult {
            result.start.imply(.day, to: date.day)
            result.start.imply(.month, to: date.month)
            result.start.imply(.year, to: date.year)
            result.start.assign(.hour, value: date.hour)
            result.start.assign(.minute, value: date.minute)
            result.start.assign(.second, value: date.second)
            result.tags[.deTimeAgoFormatParser] = true
            return result
        }
        if try NSRegularExpression.isMatch(forPattern: "stunde", in: matchText3) {
            date = number != HALF ? try date.added(-number, .hour) : try date.added(-30, .minute)
            return ymdResult()
        } else if try NSRegularExpression.isMatch(forPattern: "minute", in: matchText3) {
            date = number != HALF ? try date.added(-number, .minute) : try date.added(-30, .second)
            return ymdResult()
        } else if try NSRegularExpression.isMatch(forPattern: "sekunde", in: matchText3) {
            date = number != HALF ? try date.added(-number, .second) : try date.added(-HALF_SECOND_IN_MS, .nanosecond)
            return ymdResult()
        }
        
        if try NSRegularExpression.isMatch(forPattern: "woche", in: matchText3) {
            date = number != HALF ? try date.added(-number * 7, .day) : try date.added(-3, .day).added(-12, .hour)
            
            result.start.imply(.day, to: date.day)
            result.start.imply(.month, to: date.month)
            result.start.imply(.year, to: date.year)
            result.start.imply(.weekday, to: date.weekday)
            result.tags[.deTimeAgoFormatParser] = true
            return result
        } else if try NSRegularExpression.isMatch(forPattern: "tag", in: matchText3) {
            date = number != HALF ? try date.added(-number, .day) : try date.added(-12, .hour)
        } else if try NSRegularExpression.isMatch(forPattern: "monat", in: matchText3) {
            date = number != HALF ? try date.added(-number, .month) : try date.added(-(date.numberOf(.day, inA: .month) ?? 30)/2, .day)
        } else if try NSRegularExpression.isMatch(forPattern: "jahr", in: matchText3) {
            date = number != HALF ? try date.added(-number, .year) : try date.added(-6, .month)
        }
        
        result.start.assign(.day, value: date.day)
        result.start.assign(.month, value: date.month)
        result.start.assign(.year, value: date.year)
        result.tags[.deTimeAgoFormatParser] = true
        return result
    }
}
