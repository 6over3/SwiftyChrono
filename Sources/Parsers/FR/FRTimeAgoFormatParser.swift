//
//  FRTimeAgoFormatParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/6/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\W|^)il y a\\s*([0-9]+|une?)\\s*(minutes?|heures?|semaines?|jours?|mois|années?|ans?)(?=(?:\\W|$))"

public class FRTimeAgoFormatParser: Parser {
  override var pattern: String { return PATTERN }
  override var language: Language { return .french }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: matchText)
    result.tags[.frTimeAgoFormatParser] = true
    let amount = try RelativeDateAmount(
      text: match.string(from: text, atRangeIndex: 2), language: language)
    let unit = try RelativeDateUnit(
      text: match.string(from: text, atRangeIndex: 3), language: language)
    try result.applyOffset(amount: amount, unit: unit, direction: .past)
    return result
  }
}
