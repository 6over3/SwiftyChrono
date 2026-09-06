//
//  RUWeekdayParser.swift
//  SwiftyChrono
//
//  Created by Nickolay Truhin on 06.04.2021.
//

import Foundation

private let DAYS_OFFSET = Dictionary(uniqueKeysWithValues: RU_WEEKDAY_OFFSET.map { ($0.key.count == 2 ? $0.key + "." : $0.key, $0.value) })

private let PATTERN = "(\\W|^)" +
    "(?:(?:\\,|\\(|\\（)\\s*)?" +
    "(?:в\\s*?)?" +
    "(?:(эту|это|этот|прошлый|прошлую|прошлое|прошлая|следующий|следующую|следующее|следующая)\\s*)?" +
    "(" + DAYS_OFFSET.keys.joined(separator: "|") + ")" +
    "(?:\\s*(?:\\,|\\)|\\）))?" +
    "(?:\\s*(этой|прошлой|следующей)\\s*недели)?" +
    "(?=\\W|$)"

private let prefixGroup = 2
private let weekdayGroup = 3
private let postfixGroup = 4

public class RUWeekdayParser: Parser {
    override var pattern: String { PATTERN }
    override var language: Language { .russian }
    
    override public func extract(text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]) throws -> ParsedResult? {
        let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        let dayOfWeek = try match.string(from: text, atRangeIndex: weekdayGroup).lowercased()
        guard let offset = DAYS_OFFSET[dayOfWeek] else {
            return nil
        }
        
        let prefix: String? = match.isNotEmpty(atRangeIndex: prefixGroup) ? try match.string(from: text, atRangeIndex: prefixGroup) : nil
        let postfix: String? = match.isNotEmpty(atRangeIndex: postfixGroup) ? try match.string(from: text, atRangeIndex: postfixGroup) : nil
        let modifier: WeekdayReference
        switch (prefix ?? postfix)?.lowercased() {
        case nil: modifier = .nearest
        case "прошлый", "прошлую", "прошлое", "прошлая", "прошлой": modifier = .previousWeek
        case "следующий", "следующую", "следующее", "следующая", "следующей": modifier = .nextWeek
        case "эту", "это", "этот", "этой": modifier = .currentWeek
        default: throw ChronoError.invalidSourceRange
        }
        
        try result.start.assignWeekday(offset, relativeTo: ref, reference: modifier)
        result.tags[.ruWeekdayParser] = true
        return result
    }
}
