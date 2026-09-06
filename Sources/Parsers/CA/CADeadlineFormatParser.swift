//
//  CADeadlineFormatParser.swift
//  SwiftyChrono
//
//  Translated from ESDeadlineFormatParser.swift.
//  Original work Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN =
  "(\\W|^)(d['’]aquí(?:\\s+a)?|dins\\s*(?:de|d['’])|dintre\\s*(?:de|d['’])|en)\\s*"
  + "(\(CA_INTEGER_WORDS_PATTERN)|[+-]?[0-9]+(?:[.,][0-9]+)?|mig|mitja|una?)\\s*"
  + "(segons?|minuts?|hores|hora|dies|dia|setmanes?|mesos|mes|anys?)\\s*(?=\\W|$)"

public class CADeadlineFormatParser: Parser {
  override var pattern: String { return PATTERN }
  override var language: Language { return .catalan }

  override public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let (matchText, index) = try matchTextAndIndex(from: text, andMatchResult: match)
    var result = ParsedResult(ref: ref, index: index, text: matchText)
    result.tags[.caDeadlineFormatParser] = true
    let relation = try match.string(from: text, atRangeIndex: 2).lowercased()
    guard relation.hasPrefix("d'aquí") || relation.hasPrefix("d’aquí") else {
      result.issues.append(.unresolvedComposition)
      return result
    }
    let amount = try RelativeDateAmount(
      text: match.string(from: text, atRangeIndex: 3), language: language)
    let unit = try RelativeDateUnit(
      text: match.string(from: text, atRangeIndex: 4), language: language)
    try result.applyOffset(amount: amount, unit: unit, direction: .future)
    return result
  }
}
