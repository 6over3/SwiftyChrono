//
//  ENCasualTimeParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/18/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "(\\W|^)((this)?\\s*(morning|afternoon|evening|noon))"
private let timeMatch = 4

public class ENCasualTimeParser: Parser {
    override var pattern: String { return PATTERN }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        if match.isNotEmpty(atRangeIndex: timeMatch) {
            let time = try match.string(from: text, atRangeIndex: timeMatch)
            switch time {
            case "afternoon":
                result.start.imply(.hour, to: opt[.afternoon] ?? 15)
            case "evening":
                result.start.imply(.hour, to: opt[.evening] ?? 18)
            case "morning":
                result.start.imply(.hour, to: opt[.morning] ?? 6)
            case "noon":
                result.start.imply(.hour, to: opt[.noon] ?? 12)
            default: break
            }
        }
        
        result.tags[.enCasualTimeParser] = true
        return result
    }
}
