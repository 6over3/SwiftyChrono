//
//  ENSlashMonthFormatParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/23/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

/*
 Month/Year date format with slash "/" (also "-" and ".") between numbers
 - 11/05
 - 06/2005
 */

private let PATTERN = "(^|[^\\d/]\\s+|[^\\w\\s])" +
    "([0-9]|0[1-9]|1[012])/([0-9]{4})" +
    "([^\\d/]|$)"

private let openningGroup = 1
private let endingGroup = 4

private let monthGroup = 2
private let yearGroup = 3

public class ENSlashMonthFormatParser: Parser {
    override var pattern: String { return PATTERN }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let openGroup = match.isNotEmpty(atRangeIndex: openningGroup) ? try match.string(from: text, atRangeIndex: openningGroup) : ""
        let endGroup = match.isNotEmpty(atRangeIndex: endingGroup) ? try match.string(from: text, atRangeIndex: endingGroup) : ""
        let fullMatchText = try match.string(from: text, atRangeIndex: 0)
        let index = match.range(at: 0).location + match.range(at: openningGroup).length
        let matchText = try fullMatchText.substring(from: openGroup.utf16.count, to: fullMatchText.utf16.count - endGroup.utf16.count).trimmed()
        
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        result.start.imply(.day, to: 1)
        result.start.assign(.month, value: Int(try match.string(from: text, atRangeIndex: monthGroup)))
        result.start.assign(.year, value: Int(try match.string(from: text, atRangeIndex: yearGroup)))
        
        result.tags[.enSlashMonthFormatParser] = true
        return result
    }
}
