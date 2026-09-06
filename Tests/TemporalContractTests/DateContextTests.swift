import Foundation
import Testing

@testable import SwiftyChrono

@Suite("Composed dates preserve every operand")
struct DateContextTests {
  @Test("A weekday resolves within its written week, not nearest to today")
  func weekdayInWeek() throws {
    let result = try one("Monday of last week", language: .english)
    #expect(result.issues.isEmpty)
    #expect(result.start[.year] == 2025)
    #expect(result.start[.month] == 12)
    #expect(result.start[.day] == 22)
    #expect(result.end == nil)
  }

  @Test(arguments: [
    ("January 5 of last year", Language.english),
    ("5 janvier de l’année dernière", .french),
    ("5 de enero del año pasado", .spanish),
    ("5 de gener de l'any passat", .catalan),
    ("5. Januar letzten Jahres", .german),
    ("5 января прошлого года", .russian),
    ("去年の1月5日", .japanese),
    ("去年1月5日", .chineseSimplified),
    ("去年1月5日", .chinese),
  ])
  func dateInYear(text: String, language: Language) throws {
    let result = try one(text, language: language)
    #expect(result.issues.isEmpty)
    #expect(result.start[.year] == 2025)
    #expect(result.start[.month] == 1)
    #expect(result.start[.day] == 5)
    #expect(result.end == nil)
  }

  @Test("A month keeps month precision when its year comes from context")
  func monthInYear() throws {
    let result = try one("January of last year", language: .english)
    #expect(result.issues.isEmpty)
    #expect(result.start[.year] == 2025)
    #expect(result.start[.month] == 1)
    #expect(!result.start.isCertain(component: .day))
    #expect(result.end == nil)
  }

  @Test(arguments: [
    "Monday last month", "last Monday of next week", "today last week",
    "January 5, 2024 of last year", "February 30 of last year",
  ])
  func cannotDiscardConflictsOrSelectOneOfSeveralDays(text: String) throws {
    let result = try one(text, language: .english)
    #expect(!result.issues.isEmpty)
  }

  @Test(arguments: [
    ("Monday before 3pm", Language.english), ("Monday after 3pm", .english),
    ("Montag vor 15:00", .german), ("Montag nach 15:00", .german),
    ("понедельник после 15:00", .russian), ("понедельник до 15:00", .russian),
    ("lundi avant 15:00", .french), ("lundi après 15:00", .french),
    ("lundi vers 15:00", .french),
  ])
  func comparisonsCannotBecomeAnExactClock(text: String, language: Language) throws {
    let result = try one(text, language: language)
    #expect(!result.issues.isEmpty)
  }

  @Test(arguments: ["Monday and last week", "Monday discussing last week"])
  func unrelatedOperandsAreNotMerged(text: String) throws {
    let results = try parse(text, language: .english)
    #expect(results.count == 2)
    #expect(results.allSatisfy { $0.issues.isEmpty })
  }

  @Test("Date context is resolved before applying a clock")
  func contextThenClock() throws {
    let result = try one("January 5 of last year at 3pm", language: .english)
    #expect(result.issues.isEmpty)
    #expect(result.start[.year] == 2025)
    #expect(result.start[.month] == 1)
    #expect(result.start[.day] == 5)
    #expect(result.start[.hour] == 15)
  }

  @Test("Explicit years cannot be changed to agree with context")
  func contradictoryYear() throws {
    let result = try one("January 5, 2024 of last year", language: .english)
    #expect(result.issues == [.invalidComponents])
    #expect(result.start[.year] == 2024)
  }

  @Test("Composed source spans keep non-ASCII prefix offsets")
  func originalSource() throws {
    let source = "📚 notes January 5 of last year"
    let results = try parse(source, language: .english)
    let result = try #require(results.first)
    #expect(results.count == 1)
    #expect(result.index == "📚 notes ".utf16.count)
    #expect(result.text == "January 5 of last year")
    #expect(result.issues.isEmpty)
  }

  @Test(
    "An explicit zone supplies the year context on either operand",
    arguments: [
      "January 5, 2024 UTC of last year", "January 5, 2024 of last year UTC",
    ])
  func sharedZone(text: String) throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))
    let now = try #require(
      calendar.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 1)))
    let results = try Chrono().parse(
      text: text, refDate: now, calendar: calendar, languages: [.english])
    try #require(results.count == 1)
    let result = try #require(results.first)
    #expect(result.text == text)
    #expect(result.issues.isEmpty)
    #expect(result.start[.year] == 2024)
    #expect(result.start.timeZone == TimeZone(secondsFromGMT: 0))
  }

  private func one(_ text: String, language: Language) throws -> ParsedResult {
    let results = try parse(text, language: language)
    try #require(results.count == 1)
    let result = try #require(results.first)
    #expect(result.text == text)
    return result
  }

  private func parse(_ text: String, language: Language) throws -> [ParsedResult] {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
    calendar.firstWeekday = 2
    calendar.minimumDaysInFirstWeek = 4
    let now = try #require(
      calendar.date(from: DateComponents(year: 2026, month: 1, day: 4, hour: 15)))
    return try Chrono().parse(text: text, refDate: now, calendar: calendar, languages: [language])
  }
}
