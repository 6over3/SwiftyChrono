//
//  ENWeekdayParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/23/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "(\\W|^)" +
    "(?:(?:\\,|\\(|\\（)\\s*)?" +
    "(?:on\\s*?)?" +
    "(?:(this|last|past|next)\\s*)?" +
    "(\(EN_WEEKDAY_OFFSET_PATTERN))" +
    "(?:\\s*(?:\\,|\\)|\\）))?" +
    "(?:\\s*(this|last|past|next)\\s*week)?" +
    "(?=\\W|$)"

private let prefixGroup = 2
private let weekdayGroup = 3
private let postfixGroup = 4


public class ENWeekdayParser: Parser {
    override var pattern: String { return PATTERN }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        let dayOfWeek = try match.string(from: text, atRangeIndex: weekdayGroup).lowercased()
        guard let offset = EN_WEEKDAY_OFFSET[dayOfWeek] else {
            return nil
        }
        
        let prefix: String? = match.isNotEmpty(atRangeIndex: prefixGroup) ? try match.string(from: text, atRangeIndex: prefixGroup) : nil
        let postfix: String? = match.isNotEmpty(atRangeIndex: postfixGroup) ? try match.string(from: text, atRangeIndex: postfixGroup) : nil
        let modifier: WeekdayReference
        switch (prefix ?? postfix)?.lowercased() {
        case nil: modifier = .nearest
        case "last", "past": modifier = .previousWeek
        case "next": modifier = .nextWeek
        case "this": modifier = .currentWeek
        default: throw ChronoError.invalidSourceRange
        }
        
        try result.start.assignWeekday(offset, relativeTo: ref, reference: modifier)
        result.tags[.enWeekdayParser] = true
        return result
    }
}
