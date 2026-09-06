//
//  CAWeekdayParser.swift
//  SwiftyChrono
//
//  Translated from ESWeekdayParser.swift.
//  Original work Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "(\\W|^)" +
    "(?:(?:\\,|\\(|\\（)\\s*)?" +
    "(?:(aquest|passat|pròxim|proper)\\s*)?" +
    "(\(CA_WEEKDAY_OFFSET.keys.joined(separator: "|")))" +
    "(?:\\s*(?:\\,|\\)|\\）))?" +
    "(?:\\s*(aquesta|passad|pròxima|propera)\\s*setmana)?" +
    "(?=\\W|$)"

private let prefixGroup = 2
private let weekdayGroup = 3
private let postfixGroup = 4

public class CAWeekdayParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .catalan }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        let dayOfWeek = try match.string(from: text, atRangeIndex: weekdayGroup).lowercased()
        guard let offset = CA_WEEKDAY_OFFSET[dayOfWeek] else {
            return nil
        }
        
        let prefix: String? = match.isNotEmpty(atRangeIndex: prefixGroup) ? try match.string(from: text, atRangeIndex: prefixGroup) : nil
        let postfix: String? = match.isNotEmpty(atRangeIndex: postfixGroup) ? try match.string(from: text, atRangeIndex: postfixGroup) : nil
        var modifier: WeekdayReference = .nearest
        if prefix != nil || postfix != nil {
            let norm = (prefix ?? postfix ?? "").lowercased()
            
            if norm == "passat" || norm == "passada" {
                modifier = .previousWeek
            }
            else if norm == "pròxim" || norm == "proper" || norm == "pròxima" || norm == "propera" {
                modifier = .nextWeek
            }
            else if norm == "aquest" || norm == "aquesta" {
                modifier = .currentWeek
            }
        }
        
        try result.start.assignWeekday(offset, relativeTo: ref, reference: modifier)
        result.tags[.caWeekdayParser] = true
        return result
    }
}
