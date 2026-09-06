//
//  FRWeekdayParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/6/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\s|^)" + "(?:(?:\\,|\\(|\\（)\\s*)?" + "(?:(ce)\\s*)?"
  + "(\(FR_WEEKDAY_OFFSET.keys.joined(separator: "|")))" + "(?:\\s*(?:\\,|\\)|\\）))?"
  + "(?:\\s+(?:(dernier|prochain)|(?:de\\s+la\\s+)?semaine\\s+(?<namedWeekModifier>dernière|prochaine)))?"
  + "(?=\\W|$)"

private let prefixGroup = 2
private let weekdayGroup = 3
private let postfixGroup = 4

public final class FRWeekdayParser: Parser {
  override var pattern: String { PATTERN }
  override var language: Language { .french }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (value, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: value)
    let word = try match.string(from: text, atRangeIndex: weekdayGroup).lowercased()
    guard let weekday = FR_WEEKDAY_OFFSET[word] else { throw ChronoError.invalidSourceRange }
    var references: [WeekdayReference] = []
    if match.isNotEmpty(atRangeIndex: prefixGroup) {
      references.append(
        try reference(
          for: match.string(from: text, atRangeIndex: prefixGroup), inWeek: false))
    }
    if match.isNotEmpty(atRangeIndex: postfixGroup) {
      references.append(
        try reference(
          for: match.string(from: text, atRangeIndex: postfixGroup), inWeek: false))
    }
    if let range = Range(match.range(withName: "namedWeekModifier"), in: text) {
      references.append(try reference(for: String(text[range]), inWeek: true))
    }
    try result.applyWeekday(weekday, relativeTo: ref, references: references)
    result.tags[.frWeekdayParser] = true
    return result
  }

  private func reference(for word: String, inWeek: Bool) throws -> WeekdayReference {
    switch word.lowercased() {
    case "dernier", "dernière": return inWeek ? .previousWeek : .previousOccurrence
    case "prochain", "prochaine": return inWeek ? .nextWeek : .nextOccurrence
    case "ce": return .currentWeek
    default: throw ChronoError.invalidSourceRange
    }
  }
}
