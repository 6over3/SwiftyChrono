//
//  DEWeekdayParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/8/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "(\\W|^)" +
    "(?:(?:\\,|\\(|\\（)\\s*)?" +
    "(?:a[mn]\\s*?)?" +
    "(?:(diese[nmrs]?|letzte[nmr]?|nächste[nmr]?|kommende[nrm]?)\\s*(?:woche[nr]?)?\\s*)?" +
    "(\(DE_WEEKDAY_OFFSET.keys.joined(separator: "|")))" +
    "(?:\\s*(?:\\,|\\)|\\）))?" +
    "(?:\\s*(dieser?|letzte[nr]?|nächste[nr]?|kommende[nr]?)\\s*Woche)?" +
    "(?=\\W|$)"

private let prefixGroup = 2
private let weekdayGroup = 3
private let postfixGroup = 4

public class DEWeekdayParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .german }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        let dayOfWeek = try match.string(from: text, atRangeIndex: weekdayGroup).lowercased()
        guard let offset = DE_WEEKDAY_OFFSET[dayOfWeek] else {
            return nil
        }
        
        let prefix: String? = match.isNotEmpty(atRangeIndex: prefixGroup) ? try match.string(from: text, atRangeIndex: prefixGroup) : nil
        let postfix: String? = match.isNotEmpty(atRangeIndex: postfixGroup) ? try match.string(from: text, atRangeIndex: postfixGroup) : nil
        var modifier: WeekdayReference = .nearest
        if prefix != nil || postfix != nil {
            let norm = (prefix ?? postfix ?? "").lowercased()
            
            // fix it later
            if norm.hasPrefix("letzte") {
                modifier = .previousWeek
            }
            else if norm.hasPrefix("nächste") || norm.hasPrefix("kommende") {
                modifier = .nextWeek
            }
            else if norm.hasPrefix("diese") {
                modifier = .currentWeek
            }
        }
        
        try result.start.assignWeekday(offset, relativeTo: ref, reference: modifier)
        result.tags[.deWeekdayParser] = true
        return result
    }
}
