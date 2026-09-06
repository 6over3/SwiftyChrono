//
//  ESWeekdayParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/6/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\W|^)" + "(?:(?:\\,|\\(|\\（)\\s*)?" + "(?:(este|pasado|pr[oó]ximo)\\s*)?"
  + "(\(ES_WEEKDAY_OFFSET.keys.joined(separator: "|")))" + "(?:\\s*(?:\\,|\\)|\\）))?"
  + "(?:\\s+(?:(?:de\\s+)?(esta|pasada|pr[óo]xima)\\s+semana|(?:de\\s+la\\s+)?semana\\s+(?<namedWeekModifier>pasada|pr[óo]xima)|(?<occurrenceModifier>pasado|pr[óo]ximo)))?"
  + "(?=\\W|$)"

private let prefixGroup = 2
private let weekdayGroup = 3
private let postfixGroup = 4

public final class ESWeekdayParser: Parser {
  override var pattern: String { PATTERN }
  override var language: Language { .spanish }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (value, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: value)
    let word = try match.string(from: text, atRangeIndex: weekdayGroup).lowercased()
    guard let weekday = ES_WEEKDAY_OFFSET[word] else { throw ChronoError.invalidSourceRange }
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
    result.tags[.esWeekdayParser] = true
    return result
  }

  private func reference(for word: String, inWeek: Bool) throws -> WeekdayReference {
    switch word.lowercased() {
    case "pasado", "pasada": return inWeek ? .previousWeek : .previousOccurrence
    case "próximo", "proximo", "próxima", "proxima": return inWeek ? .nextWeek : .nextOccurrence
    case "este", "esta": return .currentWeek
    default: throw ChronoError.invalidSourceRange
    }
  }
}
