//
//  DECasualTimeParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/16/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "(\\W|^)((heute|diese[nrms])?\\s*(früh|nachmittag|abend|mittag))(?=\\W|$)"
private let timeMatch = 4

public class DECasualTimeParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .german }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        if match.isNotEmpty(atRangeIndex: 3) {
            try result.start.assign(date: ref, precision: .day)
        }
        
        if match.isNotEmpty(atRangeIndex: timeMatch) {
            let time = try match.string(from: text, atRangeIndex: timeMatch).lowercased()
            switch time {
            case "früh":
                result.start.dayPeriod = DayPeriod(.morning1, language: language)
            case "nachmittag":
                result.start.dayPeriod = DayPeriod(.afternoon2, language: language)
            case "abend":
                result.start.dayPeriod = DayPeriod(.evening1, language: language)
            case "mittag":
                result.start.dayPeriod = DayPeriod(.afternoon1, language: language)
            default: break
            }
        }
        
        result.tags[.deCasualTimeParser] = true
        return result
    }
}
