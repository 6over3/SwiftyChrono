import Foundation
import Testing

@testable import SwiftyChrono

@Suite("Durations and future dates are distinct meanings")
struct DurationMeaningTests {
  @Test(arguments: [
    ("en 2 heures", Language.french), ("en deux jours", .french),
    ("en 2 hores", .catalan), ("dintre de 2 dies", .catalan),
  ])
  func durationWordingDoesNotInventADate(text: String, language: Language) throws {
    let result = try one(text, language: language)
    #expect(!result.issues.isEmpty)
  }

  @Test(arguments: [
    ("dans deux heures", Language.french), ("dentro de dos horas", .spanish),
    ("d'aquí a dues hores", .catalan), ("d’aquí a dues hores", .catalan),
    ("d'aquí dues hores", .catalan), ("d’aquí dues hores", .catalan),
  ])
  func definiteOffsets(text: String, language: Language) throws {
    let result = try one(text, language: language)
    #expect(result.issues.isEmpty)
    #expect(result.ambiguities.isEmpty)
    guard case .unique(let date) = result.start.dateResolution else {
      Issue.record("Expected one elapsed-time offset")
      return
    }
    #expect(date.instant.timeIntervalSince(result.ref.instant) == 7_200)
  }

  @Test(arguments: [
    ("in two hours", Language.english), ("in zwei Stunden", .german),
    ("en dos horas", .spanish),
  ])
  func anOffsetCanBeAnOptionalInterpretation(text: String, language: Language) throws {
    let result = try one(text, language: language)
    #expect(result.issues.isEmpty)
    #expect(result.ambiguities == [.durationOrOffset])
    guard case .unique(let date) = result.start.dateResolution else {
      Issue.record("An optional offset still needs a valid date")
      return
    }
    #expect(date.instant.timeIntervalSince(result.ref.instant) == 7_200)
  }

  @Test(arguments: [
    "in two days at 3pm", "tomorrow to in three days", "in two hours UTC",
  ])
  func compositionRetainsUncertainty(text: String) throws {
    let result = try one(text, language: .english)
    #expect(result.issues.isEmpty)
    #expect(result.ambiguities == [.durationOrOffset])
  }

  @Test(arguments: [
    ("dentro de dos semanas", Language.spanish), ("d’aquí a dues setmanes", .catalan),
  ])
  func spokenAmountsUseTheExistingCalendarArithmetic(text: String, language: Language) throws {
    let result = try one(text, language: language)
    #expect(result.issues.isEmpty)
    #expect(result.ambiguities.isEmpty)
    guard case .unique(let date) = result.start.dateResolution else {
      Issue.record("Expected one date")
      return
    }
    #expect(
      result.ref.calendar.dateComponents([.day], from: result.ref.instant, to: date.instant).day
        == 14)
  }

  @Test(arguments: [
    ("dans -2 heures", Language.french), ("dans 1,5 heures", .french),
    ("dentro de 1.5 horas", .spanish), ("d’aquí a -2 hores", .catalan),
  ])
  func invalidAmountsRetainTheWholeExpression(text: String, language: Language) throws {
    let result = try one(text, language: language)
    #expect(!result.issues.isEmpty)
  }

  private func one(_ text: String, language: Language) throws -> ParsedResult {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
    let now = try #require(
      calendar.date(from: DateComponents(year: 2026, month: 9, day: 6, hour: 15, minute: 30)))
    let results = try Chrono().parse(
      text: text, refDate: now, calendar: calendar, languages: [language])
    try #require(results.count == 1)
    let result = try #require(results.first)
    #expect(result.text == text)
    return result
  }
}
