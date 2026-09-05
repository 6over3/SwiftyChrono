//
//  FRTimeAgoFormatParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/6/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "(\\W|^)il y a\\s*([0-9]+|une?)\\s*(minutes?|heures?|semaines?|jours?|mois|années?|ans?)(?=(?:\\W|$))"



public class FRTimeAgoFormatParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .french }
    
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
        let parsedNumber = Int(numberText)
        
        if parsedNumber == nil {
            if try NSRegularExpression.isMatch(forPattern: "demi", in: numberText) {
                number = HALF
            } else {
                number = 1
            }
        } else {
            number = parsedNumber!
        }
        
        
        var date = ref
        let matchText3 = try match.string(from: text, atRangeIndex: 3)
        func ymdResult() -> ParsedResult {
            result.start.imply(.day, to: date.day)
            result.start.imply(.month, to: date.month)
            result.start.imply(.year, to: date.year)
            result.start.assign(.hour, value: date.hour)
            result.start.assign(.minute, value: date.minute)
            result.tags[.frTimeAgoFormatParser] = true
            return result
        }
        if try NSRegularExpression.isMatch(forPattern: "heure", in: matchText3) {
            date = number != HALF ? try date.added(-number, .hour) : try date.added(-30, .minute)
            return ymdResult()
        } else if try NSRegularExpression.isMatch(forPattern: "minute", in: matchText3) {
            date = number != HALF ? try date.added(-number, .minute) : try date.added(-30, .second)
            return ymdResult()
        }
        
        if try NSRegularExpression.isMatch(forPattern: "semaine", in: matchText3) {
            date = number != HALF ? try date.added(-number * 7, .day) : try date.added(-3, .day).added(-12, .hour)
            
            result.start.imply(.day, to: date.day)
            result.start.imply(.month, to: date.month)
            result.start.imply(.year, to: date.year)
            result.start.imply(.weekday, to: date.weekday)
            result.tags[.frTimeAgoFormatParser] = true
            return result
        } else if try NSRegularExpression.isMatch(forPattern: "jour", in: matchText3) {
            date = number != HALF ? try date.added(-number, .day) : try date.added(-12, .hour)
        } else if try NSRegularExpression.isMatch(forPattern: "mois", in: matchText3) {
            date = number != HALF ? try date.added(-number, .month) : try date.added(-(date.numberOf(.day, inA: .month) ?? 30)/2, .day)
        } else if try NSRegularExpression.isMatch(forPattern: "années?|ans?", in: matchText3) {
            date = number != HALF ? try date.added(-number, .year) : try date.added(-6, .month)
        }
        
        result.start.assign(.day, value: date.day)
        result.start.assign(.month, value: date.month)
        result.start.assign(.year, value: date.year)
        result.tags[.frTimeAgoFormatParser] = true
        return result
    }
}

