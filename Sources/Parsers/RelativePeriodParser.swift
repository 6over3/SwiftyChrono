import Foundation

enum RelativePeriodModifier: String, CaseIterable {
  case previous, current, next, past
}

/// Language rules recognize operands; calendar and rolling-period arithmetic
/// share one implementation for every admitted grammar.
struct RelativePeriodRule {
  let language: Language
  let pattern: String

  static func words(_ language: Language, _ expression: String) -> Self {
    Self(
      language: language,
      pattern: "(?<![\\p{L}\\p{N}_])(?<period>\(expression))(?=$|[^\\p{L}\\p{N}_])")
  }

  static func unspaced(_ language: Language, _ expression: String) -> Self {
    Self(language: language, pattern: "(?<period>\(expression))")
  }

  static var all: [Self] {
    english + spanish + catalan + french + german + russian + japanese + simplifiedChinese
      + traditionalChinese
  }
}

final class RelativePeriodParser: Parser {
  let rule: RelativePeriodRule
  override var language: Language { rule.language }
  override var pattern: String { rule.pattern }

  init(rule: RelativePeriodRule) {
    self.rule = rule
    super.init(strictMode: false)
  }

  override func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let range = match.range(withName: "period")
    guard let source = Range(range, in: text),
      let modifier = RelativePeriodModifier.allCases.first(where: {
        match.range(withName: $0.rawValue).location != NSNotFound
      }), let unitRange = Range(match.range(withName: "unit"), in: text)
    else { throw ChronoError.invalidSourceRange }
    let amount: RelativeDateAmount?
    if let amountRange = Range(match.range(withName: "amount"), in: text) {
      amount = try RelativeDateAmount(text: String(text[amountRange]), language: language)
    } else {
      amount = nil
    }
    let unit = try RelativeDateUnit(text: String(text[unitRange]), language: language)
    var result = ParsedResult(ref: ref, index: range.location, text: String(text[source]))
    result.tags[.relativePeriodParser] = true
    try result.assignPeriod(modifier: modifier, amount: amount, unit: unit)
    return result
  }
}

extension ParsedResult {
  mutating func assignPeriod(
    modifier: RelativePeriodModifier, amount: RelativeDateAmount?, unit: RelativeDateUnit
  ) throws {
    let direction: RelativeDateDirection = modifier == .next ? .future : .past
    if amount == nil && modifier != .past {
      let anchor: ChronoDate
      if modifier == .current {
        anchor = ref
      } else {
        anchor = try ref.offset(amount: .whole(1), unit: unit, direction: direction).date
      }
      guard
        let interval = ref.calendar.dateInterval(of: unit.calendarComponent, for: anchor.instant)
      else { throw ChronoError.invalidDate }
      let precision: RelativeDateUnit
      switch unit {
      case .week, .month, .year: precision = .day
      default: precision = unit
      }
      try assignRange(interval, precision: precision)
    } else {
      guard modifier != .current else { throw ChronoError.invalidDate }
      let quantity: RelativeDateAmount
      if let amount { quantity = amount } else { quantity = .whole(1) }
      try applyRollingRange(amount: quantity, unit: unit, direction: direction)
    }
  }
}
