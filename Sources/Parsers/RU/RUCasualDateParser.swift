//
//  RUCasualDateParser.swift
//  SwiftyChrono
//
//  Created by Nickolay Truhin on 06.04.2021.
//

import Foundation

private let PATTERN = "(\\W|^)(сегодня ночью|сегодня|вчера|прошлым\\s*вечером|прошлой\\s*ночью|(?:завтра|вчера)\\s*|послезавтра|позавчера)(?=\\W|$)"

public class RUCasualDateParser: Parser {
    override var pattern: String { PATTERN }
    override var language: Language { .russian }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        let refMoment = ref
        var startMoment = refMoment
        let lowerText = matchText.lowercased()
        
        if lowerText == "сегодня ночью" {
            result.start.dayPeriod = DayPeriod(.night1, language: language)
            
        } else if try NSRegularExpression.isMatch(forPattern: "^завтра", in: lowerText) {
            startMoment = try startMoment.added(1, .day)
        } else if try NSRegularExpression.isMatch(forPattern: "^послезавтра", in: lowerText) {
            startMoment = try startMoment.added(2, .day)
        } else if try NSRegularExpression.isMatch(forPattern: "^вчера", in: lowerText) {
            startMoment = try startMoment.added(-1, .day)
        } else if try NSRegularExpression.isMatch(forPattern: "^позавчера", in: lowerText) {
            startMoment = try startMoment.added(-2, .day)
        } else if try NSRegularExpression.isMatch(forPattern: "прошлой\\s*ночью", in: lowerText) {
            result.start.dayPeriod = DayPeriod(.night1, language: language)
            startMoment = try startMoment.added(-1, .day)
        } else if try NSRegularExpression.isMatch(forPattern: "прошлым\\s*вечером", in: lowerText) {
            result.start.dayPeriod = DayPeriod(.evening1, language: language)
            startMoment = try startMoment.added(-1, .day)
        }
        
        result.start.assign(.day, value: startMoment.day)
        result.start.assign(.month, value: startMoment.month)
        result.start.assign(.year, value: startMoment.year)
        result.tags[.ruCasualDateParser] = true
        return result
    }
}
