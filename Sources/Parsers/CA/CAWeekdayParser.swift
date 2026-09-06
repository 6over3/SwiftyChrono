//
//  CAWeekdayParser.swift
//  SwiftyChrono
//
//  Translated from ESWeekdayParser.swift.
//  Original work Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\W|^)" + "(?:(?:\\,|\\(|\\（)\\s*)?" + "(?:(aquest|passat|pròxim|proper)\\s*)?"
  + "(\(CA_WEEKDAY_OFFSET.keys.sorted { $0.utf8.count != $1.utf8.count ? $0.utf8.count > $1.utf8.count : $0 < $1 }.map(NSRegularExpression.escapedPattern(for:)).joined(separator: "|")))"
  + "(?:\\s*(?:\\,|\\)|\\）))?"
  + "(?:\\s+(?:(?:de\\s+|d['’])?(aquesta|passada|pròxima|propera)\\s+setmana|(?:de\\s+la\\s+)?setmana\\s+(?<namedWeekModifier>passada|pròxima|propera)|(?<occurrenceModifier>passat|pròxim|proper)))?"
  + "(?=\\W|$)"

private let prefixGroup = 2
private let weekdayGroup = 3
private let postfixGroup = 4

public final class CAWeekdayParser: Parser {
  override var pattern: String { PATTERN }
  override var language: Language { .catalan }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (value, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: value)
    let word = try match.string(from: text, atRangeIndex: weekdayGroup).lowercased()
    guard let weekday = CA_WEEKDAY_OFFSET[word] else { throw ChronoError.invalidSourceRange }
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
    for (name, inWeek) in [("namedWeekModifier", true), ("occurrenceModifier", false)] {
      if let range = Range(match.range(withName: name), in: text) {
        references.append(try reference(for: String(text[range]), inWeek: inWeek))
      }
    }
    try result.applyWeekday(weekday, relativeTo: ref, references: references)
    result.tags[.caWeekdayParser] = true
    return result
  }

  private func reference(for word: String, inWeek: Bool) throws -> WeekdayReference {
    switch word.lowercased() {
    case "passat", "passada": return inWeek ? .previousWeek : .previousOccurrence
    case "pròxim", "proper", "pròxima", "propera": return inWeek ? .nextWeek : .nextOccurrence
    case "aquest", "aquesta": return .currentWeek
    default: throw ChronoError.invalidSourceRange
    }
  }
}
