//
//  CACasualDateParser.swift
//  SwiftyChrono
//
//  Translated from ESCasualDateParser.swift.
//  Original work Copyright © 2017 Potix. All rights reserved.
//

import Foundation

/*
 Valid patterns:
 - aquest matí -> today in the morning
 - aquesta tarda -> today in the afternoon/evening
 - aquesta nit -> tonight
 - ahir pel matí -> yesterday in the morning
 - ahir per la tarda -> yesterday in the afternoon/evening
 - ahir per la nit -> yesterday at night
 - demà pel matí -> tomorrow in the morning
 - demà per la tarda -> tomorrow in the afternoon/evening
 - demà per la nit -> tomorrow at night
 - ahir a la nit -> tomorrow at night
 - avui -> today
 - ahir -> yesterday
 - demà -> tomorrow
 */
private let PATTERN = "(\\W|^)(aquesta?\\s*(matí|tarda|nit)|(ahir|demà)\\s*(per\\s*la|pel)\\s*(matí|tarda|nit)|avui|demà|ahir\\s+(a|per)\\s+la\\s+nit|ahir)(?=\\W|$)"

public class CACasualDateParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .catalan }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        let refMoment = ref
        var startMoment = refMoment
        let regex = try! NSRegularExpression(pattern: "\\s+")
        let lowerText = regex.stringByReplacingMatches(in: matchText.lowercased(), range: NSRange(location: 0, length: matchText.utf16.count), withTemplate: " ")
        
        if lowerText == "demà" {
            startMoment = try startMoment.added(1, .day)
            
        } else if lowerText == "ahir" {
            
            startMoment = try startMoment.added(-1, .day)
            
        } else if try NSRegularExpression.isMatch(forPattern: "ahir\\s+a\\s+la\\s+nit", in: lowerText) {
            result.start.imply(.hour, to: 0)
            startMoment = try startMoment.added(-1, .day)

        } else if try NSRegularExpression.isMatch(forPattern: "aquest", in: lowerText) {
            
            let secondMatch = try match.string(from: text, atRangeIndex: 3).lowercased()
            if secondMatch == "tarda" {
                result.start.imply(.hour, to: 18)
                
            } else if secondMatch == "matí" {
                result.start.imply(.hour, to: 6)
                
            } else if (secondMatch == "nit") {
                
                // Normally means this coming midnight
                result.start.imply(.hour, to: 22)
                result.start.imply(.meridiem, to: 1)
                
            }
        
        } else if try NSRegularExpression.isMatch(forPattern: "(?:per\\s*la|pel)", in: lowerText) {
            let firstMatch = try match.string(from: text, atRangeIndex: 4).lowercased()
            if firstMatch == "ahir" {
                startMoment = try startMoment.added(-1, .day)
                
            } else if firstMatch == "demà" {
                startMoment = try startMoment.added(1, .day)
                
            }
            
            
            let secondMatch = try match.string(from: text, atRangeIndex: 5).lowercased()
            if secondMatch == "tarda" {
                result.start.imply(.hour, to: 18)
                
            } else if secondMatch == "demà" {
                result.start.imply(.hour, to: 9)
                
            } else if secondMatch == "nit" {
                
                // Normally means this coming midnight
                result.start.imply(.hour, to: 22)
                result.start.imply(.meridiem, to: 1)
                
            }
            
        }
        
        result.start.assign(.day, value: startMoment.day)
        result.start.assign(.month, value: startMoment.month)
        result.start.assign(.year, value: startMoment.year)
        result.tags[.caCasualDateParser] = true
        return result
    }
}
