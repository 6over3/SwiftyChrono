//
//  DEMorgenTimeParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/18/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

/* this is a white list for morning cases
 * e.g.
 * this morning => heute Morgen
 * tomorrow morning => Morgen früh
 * friday morning => Freitag Morgen
 * last morning => letzten Morgen
 */
private let PATTERN = "(\\W|^)((?:heute|letzten)\\s*Morgen|Morgen\\s*früh|\(DE_WEEKDAY_WORDS_PATTERN)\\s*Morgen)"
private let timeMatch = 2

public class DEMorgenTimeParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .german }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        result.start.dayPeriod = DayPeriod(.morning1, language: language)
        
        let time = try match.string(from: text, atRangeIndex: timeMatch).lowercased()
        
        if time.hasPrefix("letzten") {
            try result.start.assign(date: ref.added(-1, .day), precision: .day)
        } else if time.hasSuffix("früh") {
            try result.start.assign(date: ref.added(1, .day), precision: .day)
        } else if time.hasPrefix("heute") {
            try result.start.assign(date: ref, precision: .day)
        } else {
            if let weekday = try DE_WEEKDAY_OFFSET[time.substring(from: 0, to: time.utf16.count - "Morgen".utf16.count).trimmed()] {
                
                try result.start.assignWeekday(weekday, relativeTo: ref, reference: .nearest)
            }
        }
        
        result.tags[.deMorgenTimeParser] = true
        return result
    }
}
