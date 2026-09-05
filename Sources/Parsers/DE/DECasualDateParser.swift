//
//  DECasualDateParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/7/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "(\\W|^)(jetzt|heute|letzte\\s*Nacht|(?:morgen|gestern)\\s*|morgen|gestern)(?=\\W|$)"

public class DECasualDateParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .german }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        let refMoment = ref
        var startMoment = refMoment
        let lowerText = matchText.lowercased()
        
        if try NSRegularExpression.isMatch(forPattern: "^morgen", in: lowerText) {
            startMoment = try startMoment.added(1, .day)
        } else if try NSRegularExpression.isMatch(forPattern: "^gestern", in: lowerText) {
            startMoment = try startMoment.added(-1, .day)
        } else if try NSRegularExpression.isMatch(forPattern: "letzte\\s*Nacht", in: lowerText) {
            result.start.imply(.hour, to: 0)
            startMoment = try startMoment.added(-1, .day)
        } else if try NSRegularExpression.isMatch(forPattern: "jetzt", in: lowerText) {
            result.start.imply(.hour, to: refMoment.hour)
            result.start.imply(.minute, to: refMoment.minute)
            result.start.imply(.second, to: refMoment.second)
            result.start.imply(.millisecond, to: refMoment.millisecond)
        }
        
        result.start.assign(.day, value: startMoment.day)
        result.start.assign(.month, value: startMoment.month)
        result.start.assign(.year, value: startMoment.year)
        result.tags[.deCasualDateParser] = true
        return result
    }
}
