//
//  RUWeekdayParser.swift
//  SwiftyChrono
//
//  Created by Nickolay Truhin on 06.04.2021.
//

import Foundation

private let DAYS_OFFSET = Dictionary(
  uniqueKeysWithValues: RU_WEEKDAY_OFFSET.map {
    ($0.key.count == 2 ? $0.key + "." : $0.key, $0.value)
  })

private let PATTERN =
  "(\\W|^)" + "(?:(?:\\,|\\(|\\（)\\s*)?" + "(?:в\\s*?)?"
  + "(?:(эту|это|этот|прошлый|прошлую|прошлое|прошлая|следующий|следующую|следующее|следующая)\\s*)?"
  + "("
  + DAYS_OFFSET.keys.sorted().map(NSRegularExpression.escapedPattern(for:)).joined(separator: "|")
  + ")" + "(?:\\s*(?:\\,|\\)|\\）))?" + "(?:\\s*(этой|прошлой|следующей)\\s*недели)?" + "(?=\\W|$)"

private let prefixGroup = 2
private let weekdayGroup = 3
private let postfixGroup = 4

public final class RUWeekdayParser: Parser {
  override var pattern: String { PATTERN }
  override var language: Language { .russian }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (value, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: value)
    let word = try match.string(from: text, atRangeIndex: weekdayGroup).lowercased()
    guard let weekday = DAYS_OFFSET[word] else { throw ChronoError.invalidSourceRange }
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
    result.tags[.ruWeekdayParser] = true
    return result
  }

  private func reference(for word: String, inWeek: Bool) throws -> WeekdayReference {
    switch word.lowercased() {
    case "прошлый", "прошлую", "прошлое", "прошлая", "прошлой":
      return inWeek ? .previousWeek : .previousOccurrence
    case "следующий", "следующую", "следующее", "следующая", "следующей":
      return inWeek ? .nextWeek : .nextOccurrence
    case "эту", "это", "этот", "этой": return .currentWeek
    default: throw ChronoError.invalidSourceRange
    }
  }
}
