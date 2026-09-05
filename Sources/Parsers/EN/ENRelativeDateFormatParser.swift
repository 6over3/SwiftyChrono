//
//  ENRelativeDateFormatParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/23/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\W|^)" + "(next|last|past)\\s*"
  + "(\(EN_INTEGER_WORDS_PATTERN)|[0-9]+|few|half(?:\\s*an?)?)?\\s*"
  + "(seconds?|min(?:ute)?s?|hours?|days?|weeks?|months?|years?)(?=\\s*)" + "(?=\\W|$)"

private let modifierWordGroup = 2
private let multiplierWordGroup = 3
private let relativeWordGroup = 4

public class ENRelativeDateFormatParser: Parser {
  override var pattern: String { return PATTERN }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: matchText)
    result.tags[.enRelativeDateFormatParser] = true
    let modifier = try match.string(from: text, atRangeIndex: modifierWordGroup).lowercased()
    let numberText = try match.string(from: text, atRangeIndex: multiplierWordGroup)
    let unit = try RelativeDateUnit(
      text: match.string(from: text, atRangeIndex: relativeWordGroup), language: language)
    let direction: RelativeDateDirection = modifier == "next" ? .future : .past
    if numberText.isEmpty && modifier != "past" {
      // An unquantified next/last unit names an adjacent complete calendar period.
      let shifted = try ref.offset(amount: .whole(1), unit: unit, direction: direction).date
      guard let period = ref.calendar.dateInterval(of: unit.calendarComponent, for: shifted.instant)
      else { throw ChronoError.invalidDate }
      let precision: RelativeDateUnit
      switch unit {
      case .week, .month, .year: precision = .day
      default: precision = unit
      }
      try result.assignRange(period, precision: precision)
    } else {
      // Quantified periods and "past" are rolling ranges at the captured second.
      let amount =
        try numberText.isEmpty
        ? RelativeDateAmount.whole(1)
        : RelativeDateAmount(text: numberText, language: language)
      if case .half = amount, unit == .second {
        result.issues.append(.unsupportedPrecision)
        return result
      }
      let reference = ChronoDate(
        instant: Date(timeIntervalSince1970: floor(ref.timeIntervalSince1970)),
        calendar: ref.calendar)
      let shifted = try reference.offset(amount: amount, unit: unit, direction: direction).date
      let lower = direction == .past ? shifted.instant : reference.instant
      let upper = direction == .past ? reference.instant : shifted.instant
      guard lower < upper else { throw ChronoError.invalidDate }
      try result.assignRange(DateInterval(start: lower, end: upper), precision: .second)
    }
    return result
  }
}
