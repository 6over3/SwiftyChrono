//
//  RUDeadlineDateParser.swift
//  SwiftyChrono
//
//  Created by Nickolay Truhin on 06.04.2021.
//

import Foundation

private let PATTERN =
  "(\\W|^)" + "(через|спустя)\\s*" + "(" + RU_INTEGER_WORDS_PATTERN
  + "|[0-9]+|несколько|одну|один\\s*пол|одну)?\\s*"
  + "((секунда|секунд|секунды|секунду)|(минут|минуту|минуты)|(часов|час|часа)|(дней|день|дня)|(недель|неделю|неделя|недели)|(месяцев|месяц|месяца)|(лет|год|года))\\s*"
  + "(?=\\W|$)"

private let STRICT_PATTERN =
  "(\\W|^)" + "(через|спустя)\\s*" + "(" + RU_INTEGER_WORDS_PATTERN + "|[0-9]+|одну(?:r|m)?)\\s*"
  + "((секунд|секунду|секунды)|(минут|минуту|минуты)|(часов|часа|час)|(дней|день|дня))\\s*"
  + "(?=\\W|$)"

public class RUDeadlineFormatParser: Parser {
  override var pattern: String { strictMode ? STRICT_PATTERN : PATTERN }
  override var language: Language { .russian }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: matchText)
    result.tags[.ruDeadlineFormatParser] = true
    let amount = try RelativeDateAmount(
      text: match.string(from: text, atRangeIndex: 3), language: language)
    let unit = try RelativeDateUnit(
      text: match.string(from: text, atRangeIndex: 4), language: language)
    try result.applyOffset(amount: amount, unit: unit, direction: .future)
    return result
  }
}
