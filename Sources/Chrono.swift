// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

public enum OptionType: String {
  case morning, afternoon, evening, noon, forwardDate
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
      var results: [ParsedResult] = []
      for parser in modeOption.parsers
      where parser.language == language || parser.language == .neutral {
        results += try parser.execute(text: text, ref: reference, opt: opt)
      }
      results.sort { $0.index < $1.index }
      for refiner in modeOption.refiners
      where refiner.language == .neutral || refiner.language == language {
        results = try refiner.refine(text: text, results: results, opt: opt)
      }
      combined += results
    }
    return combined
  }
}
