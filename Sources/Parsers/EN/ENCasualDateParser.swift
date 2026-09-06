//
//  ENCasualDateParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/19/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "(\\W|^)(today|tonight|last\\s*night|(?:tomorrow|tmr|yesterday)\\s*|tomorrow|tmr|yesterday)(?=\\W|$)"

public class ENCasualDateParser: Parser {
    override var pattern: String { return PATTERN }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        let refMoment = ref
        var startMoment = refMoment
        let lowerText = matchText.lowercased()
        
        if lowerText == "tonight" {
            // Normally means this coming midnight
            result.start.imply(.hour, to: 22)
            result.start.imply(.meridiem, to: 1)
            
        } else if try NSRegularExpression.isMatch(forPattern: "^tomorrow|^tmr", in: lowerText) {
            startMoment = try startMoment.added(1, .day)
        } else if try NSRegularExpression.isMatch(forPattern: "^yesterday", in: lowerText) {
            startMoment = try startMoment.added(-1, .day)
        } else if try NSRegularExpression.isMatch(forPattern: "last\\s*night", in: lowerText) {
            result.start.imply(.hour, to: 0)
            startMoment = try startMoment.added(-1, .day)
        }
        
        result.start.assign(.day, value: startMoment.day)
        result.start.assign(.month, value: startMoment.month)
        result.start.assign(.year, value: startMoment.year)
        result.tags[.enCasualDateParser] = true
        return result
    }
}
