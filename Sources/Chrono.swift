// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

public enum OptionType: String {
  case forwardDate
}

/// Language grammars share explicit per-call context, never global date settings.
public struct Chrono {
  private let modeOption: ModeOptio

  public init(strict: Bool = false) {
    modeOption = strict ? strictModeOption() : casualModeOption()
  }

  public func parse(
    text: String,
    refDate: Date,
    calendar: Calendar,
    languages: Set<Language>,
    opt: [OptionType: Int] = [:]
  ) throws -> [ParsedResult] {
    // These grammars describe civil Gregorian dates, not arbitrary era calendars.
    guard calendar.identifier == .gregorian,
      refDate.timeIntervalSince1970.isFinite
    else { throw ChronoError.invalidCalendar }
    let reference = ChronoDate(instant: refDate, calendar: calendar)
    var combined: [ParsedResult] = []
    // Resolve each admitted grammar independently. Parser registration order
    // must not discard another language's interpretation of the same date.
    for language in Language.allCases where languages.contains(language) {
      combined += try parseOnce(
        text: text, reference: reference, language: language,
        opt: opt, rebaseComposedZones: true)
    }
    return combined
  }

  private func parseOnce(
    text: String, reference: ChronoDate, language: Language, opt: [OptionType: Int],
    rebaseComposedZones: Bool
  ) throws -> [ParsedResult] {
    var results: [ParsedResult] = []
    for parser in modeOption.parsers
    where parser.language == language || parser.language == .neutral {
      results += try parser.execute(text: text, ref: reference, opt: opt)
    }
    results.sort { $0.index < $1.index }
    for refiner in modeOption.refiners
    where refiner.language == .neutral || refiner.language == language {
      results = try refiner.refine(text: text, results: results, opt: opt)
      if rebaseComposedZones {
        results = try results.flatMap { try resolvingSharedZone($0, language: language, opt: opt) }
      }
    }
    return results
  }

  /// A zone on one operand can supply the context of a composed expression.
  /// Re-evaluate only that expression, once, keeping the same captured instant.
  private func resolvingSharedZone(
    _ result: ParsedResult, language: Language, opt: [OptionType: Int]
  ) throws -> [ParsedResult] {
    guard result.issues.isEmpty, let zone = result.sharedTimeZone,
      result.start.calendar.timeZone != zone
        || (result.end != nil && result.end?.calendar.timeZone != zone)
    else { return [result] }
    var calendar = result.ref.calendar
    calendar.timeZone = zone
    let reference = ChronoDate(instant: result.ref.instant, calendar: calendar)
    let recalculated = try parseOnce(
      text: result.text, reference: reference, language: language,
      opt: opt, rebaseComposedZones: false)
    guard !recalculated.isEmpty,
      recalculated.allSatisfy({ $0.index == 0 && $0.text == result.text })
    else {
      var unresolved = result
      unresolved.issues.append(.invalidTimeZone)
      return [unresolved]
    }
    return recalculated.map { value in
      var rebased = value
      rebased.index += result.index
      return rebased
    }
  }
}
