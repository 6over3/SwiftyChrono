//
//  ENWeekdayParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/23/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\W|^)" + "(?:(?:\\,|\\(|\\（)\\s*)?" + "(?:on\\s*?)?" + "(?:(this|last|past|next)\\s*)?"
  + "(\(EN_WEEKDAY_OFFSET_PATTERN))" + "(?:\\s*(?:\\,|\\)|\\）))?"
  + "(?:\\s*(this|last|past|next)\\s*week)?" + "(?=\\W|$)"

private let prefixGroup = 2
private let weekdayGroup = 3
private let postfixGroup = 4

public final class ENWeekdayParser: Parser {
  override var pattern: String { PATTERN }
  override var language: Language { .english }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (value, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: value)
    let word = try match.string(from: text, atRangeIndex: weekdayGroup).lowercased()
    guard let weekday = EN_WEEKDAY_OFFSET[word] else { throw ChronoError.invalidSourceRange }
    var references: [WeekdayReference] = []
    if match.isNotEmpty(atRangeIndex: prefixGroup) {
      references.append(
        try reference(
          for: match.string(from: text, atRangeIndex: prefixGroup), inWeek: false))
    }
    if match.isNotEmpty(atRangeIndex: postfixGroup) {
      references.append(
        try reference(
          for: match.string(from: text, atRangeIndex: postfixGroup), inWeek: true))
    }
    try result.applyWeekday(weekday, relativeTo: ref, references: references)
    result.tags[.enWeekdayParser] = true
    return result
  }

  private func reference(for word: String, inWeek: Bool) throws -> WeekdayReference {
    switch word.lowercased() {
    case "last", "past": return inWeek ? .previousWeek : .previousOccurrence
    case "next": return inWeek ? .nextWeek : .nextOccurrence
    case "this": return .currentWeek
    default: throw ChronoError.invalidSourceRange
    }
  }
}
