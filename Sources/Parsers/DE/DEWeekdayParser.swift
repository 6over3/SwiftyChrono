//
//  DEWeekdayParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/8/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\W|^)" + "(?:(?:\\,|\\(|\\（)\\s*)?" + "(?:a[mn]\\s*?)?"
  + "(?:(diese[nmrs]?|letzte[nmr]?|nächste[nmr]?|kommende[nrm]?)\\s*(?<prefixWeek>woche[nr]?)?\\s*)?"
  + "(\(DE_WEEKDAY_OFFSET.keys.joined(separator: "|")))" + "(?:\\s*(?:\\,|\\)|\\）))?"
  + "(?:\\s*(dieser?|letzte[nr]?|nächste[nr]?|kommende[nr]?)\\s*Woche)?" + "(?=\\W|$)"

private let prefixGroup = 2
private let weekdayGroup = 4
private let postfixGroup = 5

public final class DEWeekdayParser: Parser {
  override var pattern: String { PATTERN }
  override var language: Language { .german }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (value, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: value)
    let word = try match.string(from: text, atRangeIndex: weekdayGroup).lowercased()
    guard let weekday = DE_WEEKDAY_OFFSET[word] else { throw ChronoError.invalidSourceRange }
    var references: [WeekdayReference] = []
    if match.isNotEmpty(atRangeIndex: prefixGroup) {
      references.append(
        try reference(
          for: match.string(from: text, atRangeIndex: prefixGroup),
          inWeek: match.range(withName: "prefixWeek").location != NSNotFound))
    }
    if match.isNotEmpty(atRangeIndex: postfixGroup) {
      references.append(
        try reference(
          for: match.string(from: text, atRangeIndex: postfixGroup), inWeek: true))
    }
    try result.applyWeekday(weekday, relativeTo: ref, references: references)
    result.tags[.deWeekdayParser] = true
    return result
  }

  private func reference(for word: String, inWeek: Bool) throws -> WeekdayReference {
    switch word.lowercased() {
    case let value where value.hasPrefix("letzte"):
      return inWeek ? .previousWeek : .previousOccurrence
    case let value where value.hasPrefix("nächste") || value.hasPrefix("kommende"):
      return inWeek ? .nextWeek : .nextOccurrence
    case let value where value.hasPrefix("diese"): return .currentWeek
    default: throw ChronoError.invalidSourceRange
    }
  }
}
