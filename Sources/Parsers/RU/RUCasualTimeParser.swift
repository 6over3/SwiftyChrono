//
//  RuCasualTimeParser.swift
//  SwiftyChrono
//
//  Created by Nickolay Truhin on 06.04.2021.
//


import Foundation

private let PATTERN = "(\\W|^)((этим|этой|в эту)?\\s*(утром|в полдень|вечером|ночью|ночь))(?=\\W|$)"
private let timeMatch = 4

public class RUCasualTimeParser: Parser {
    override var pattern: String { PATTERN }
    override var language: Language { .russian }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        if match.isNotEmpty(atRangeIndex: 3) {
            try result.start.assign(date: ref, precision: .day)
        }
        
        if match.isNotEmpty(atRangeIndex: timeMatch) {
            let time = try match.string(from: text, atRangeIndex: timeMatch).lowercased()
            switch time {
            case "вечером":
                result.start.dayPeriod = DayPeriod(.evening1, language: language)
            case "ночью", "ночь":
                result.start.dayPeriod = DayPeriod(.night1, language: language)
            case "утром":
                result.start.dayPeriod = DayPeriod(.morning1, language: language)
            case "в полдень":
                result.start.dayPeriod = DayPeriod(.noon, language: language)
            default: break
            }
        }
        
        result.tags[.ruCasualTimeParser] = true
        return result
    }
}
