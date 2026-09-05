//
//  RUMonthNameParser.swift
//  SwiftyChrono
//
//  Created by Nickolay Truhin on 06.04.2021.
//

import Foundation

private let PATTERN = "(^|\\D\\s+|[^\\w\\s])" +
    "(Янв\\.?|Января|Фев\\.?|Февраля|Мар\\.?|Марта|Апр\\.?|Апреля|Мая\\.?|Июн\\.?|Июня|Июл\\.?|Июля|Авг\\.?|Августа|Сен\\.?|Сент\\.?|Сентября|Окт\\.?|Октября|Ноя\\.?|Ноября|Дек\\.?|Декабря)" +
    "\\s*" +
    "(?:" +
        "[,-]?\\s*([0-9]{4})(\\s*BE|AD|BC)?" +
    ")?" +
    "(?=[^\\s\\w]|\\s+[^0-9]|\\s+$|$)"

private let monthNameGroup = 2
private let yearGroup = 3
private let yearBeGroup = 4

public class RUMonthNameParser: Parser {
    override var pattern: String { PATTERN }
    override var language: Language { .russian }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        guard let month = RU_MONTH_OFFSET[try match.string(from: text, atRangeIndex: monthNameGroup).lowercased()] else {
            return nil
        }
        let day = 1
        
        if match.isNotEmpty(atRangeIndex: yearGroup) {
            var year = Int(try match.string(from: text, atRangeIndex: yearGroup))!
            
            if match.isNotEmpty(atRangeIndex: yearBeGroup) {
                let yearBe = try match.string(from: text, atRangeIndex: yearBeGroup)
                
                if try NSRegularExpression.isMatch(forPattern: "BE", in: yearBe) {
                    // Buddhist Era
                    year = year - 543
                } else if try NSRegularExpression.isMatch(forPattern: "BC", in: yearBe) {
                    // Before Christ
                    year = -year
                }
            } else if year < 10 {
                // require single digit years to always have BC/AD
                return nil
            } else if year < 100 {
                year += 2000
            }
            
            result.start.imply(.day, to: day)
            result.start.assign(.month, value: month)
            result.start.assign(.year, value: year)
        } else {
            //Find the most appropriated year
            var refMoment = ref
            refMoment = try refMoment.setOrAdded(month, .month)
            refMoment = try refMoment.setOrAdded(day, .day)
            
            let nextYear = try refMoment.added(1, .year)
            let lastYear = try refMoment.added(-1, .year)
            if abs(nextYear.differenceOfTimeInterval(to: ref)) < abs(refMoment.differenceOfTimeInterval(to: ref)) {
                refMoment = nextYear
            } else if abs(lastYear.differenceOfTimeInterval(to: ref)) < abs(refMoment.differenceOfTimeInterval(to: ref)) {
                refMoment = lastYear
            }
            
            result.start.imply(.day, to: day)
            result.start.assign(.month, value: month)
            result.start.imply(.year, to: refMoment.year)
        }
        
        result.tags[.ruMonthNameParser] = true
        return result
    }
}
