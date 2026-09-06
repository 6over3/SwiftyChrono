//
//  FRCasualDateParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/6/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "(\\W|^)(aujourd'hui|ajd|cette\\s*nuit|la\\s*veille|(demain|hier)(\\s*(matin|soir|aprem|après-midi))?|ce\\s*(matin|soir)|cet\\s*(après-midi|aprem))(?=\\W|$)"

public class FRCasualDateParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .french }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        let refMoment = ref
        var startMoment = refMoment
        let lowerText = matchText.lowercased()
        
        
            
        if try NSRegularExpression.isMatch(forPattern: "demain", in: lowerText) {
            startMoment = try startMoment.added(1, .day)
        }
        
        if try NSRegularExpression.isMatch(forPattern: "hier", in: lowerText) {
            startMoment = try startMoment.added(-1, .day)
        }
        
        if try NSRegularExpression.isMatch(forPattern: "cette\\s*nuit", in: lowerText) {
            // Normally means this coming midnight
            result.start.imply(.hour, to: 22)
            result.start.imply(.meridiem, to: 1)
        } else if try NSRegularExpression.isMatch(forPattern: "la\\s*veille", in: lowerText) {
            result.start.imply(.hour, to: 0)
            startMoment = try startMoment.added(-1, .day)
        } else if try NSRegularExpression.isMatch(forPattern: "(après-midi|aprem)", in: lowerText) {
            result.start.imply(.hour, to: 14)
        } else if try NSRegularExpression.isMatch(forPattern: "(soir)", in: lowerText) {
            result.start.imply(.hour, to: 18)
        } else if try NSRegularExpression.isMatch(forPattern: "matin", in: lowerText) {
            result.start.imply(.hour, to: 8)
        }
        
        result.start.assign(.day, value: startMoment.day)
        result.start.assign(.month, value: startMoment.month)
        result.start.assign(.year, value: startMoment.year)
        result.tags[.frCasualDateParser] = true
        return result
    }
}
