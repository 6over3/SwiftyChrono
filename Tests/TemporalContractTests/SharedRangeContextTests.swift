import Foundation
import Testing

@testable import SwiftyChrono

@Suite("Date ranges retain shared calendar context")
struct SharedRangeContextTests {
  @Test(arguments: [
    ("Monday to Friday last week", Language.english),
    ("last week Monday to Friday", .english),
    ("lundi à vendredi de la semaine dernière", .french),
    ("Montag bis Freitag letzte Woche", .german),
    ("lunes a viernes de la semana pasada", .spanish),
    ("dilluns a divendres de la setmana passada", .catalan),
    ("понедельник до пятницы прошлой недели", .russian),
    ("上周一到周五", .chineseSimplified), ("上週一到週五", .chinese),
  ])
  func sharedWeek(text: String, language: Language) throws {
    let result = try one(text, language: language)
    let end = try #require(result.end)
    #expect(result.issues.isEmpty)
    #expect(result.start[.year] == 2025)
    #expect(result.start[.month] == 12)
    #expect(result.start[.day] == 22)
    #expect(end[.year] == 2025)
    #expect(end[.month] == 12)
    #expect(end[.day] == 26)
  }

  @Test(arguments: ["December to January 2026", "December 2025 to January"])
  func anOmittedYearCanCrossNewYear(text: String) throws {
    let result = try one(text, language: .english)
    let end = try #require(result.end)
    #expect(result.issues.isEmpty)
    #expect(result.start[.year] == 2025)
    #expect(result.start[.month] == 12)
    #expect(end[.year] == 2026)
    #expect(end[.month] == 1)
    #expect(!result.start.isCertain(component: .day))
    #expect(!end.isCertain(component: .day))
  }

  @Test("Independently supplied weeks must not be rewritten into one week")
  func separateWeeks() throws {
    let result = try one("Monday last week to Friday this week", language: .english)
    let end = try #require(result.end)
    #expect(result.issues.isEmpty)
    #expect(result.start[.year] == 2025)
    #expect(result.start[.day] == 22)
    #expect(end[.year] == 2026)
    #expect(end[.month] == 1)
    #expect(end[.day] == 2)
  }

  @Test("Both written years are preserved even when the range is backwards")
  func explicitYears() throws {
    let result = try one("December 2026 to January 2026", language: .english)
    let end = try #require(result.end)
    #expect(result.start[.year] == 2026)
    #expect(end[.year] == 2026)
    #expect(result.start[.month] == 12)
    #expect(end[.month] == 1)
  }

  @Test("A weekday stays inside the supplied week instead of rolling to another one")
  func backwardsWeek() throws {
    let result = try one("Friday to Monday last week", language: .english)
    let end = try #require(result.end)
    #expect(result.start[.month] == 12)
    #expect(result.start[.day] == 26)
    #expect(end[.month] == 12)
    #expect(end[.day] == 22)
  }

  @Test("Unrelated text cannot supply a shared week")
  func unrelatedWeek() throws {
    let results = try parse("Monday to Friday discussing last week", language: .english)
    #expect(results.count == 2)
    #expect(results.first?.text == "Monday to Friday")
    #expect(results.last?.text == "last week")
  }

  @Test(arguments: ["December to January of last year", "last year December to January"])
  func namedYearDoesNotPermitRollover(text: String) throws {
    let result = try one(text, language: .english)
    let end = try #require(result.end)
    #expect(result.start[.year] == 2025)
    #expect(end[.year] == 2025)
    #expect(result.start[.month] == 12)
    #expect(end[.month] == 1)
  }

  @Test(arguments: [
    ("Monday last week to Friday at 15:30", Language.english),
    ("lundi de la semaine dernière à vendredi à 15:30", .french),
  ])
  func aClockOnlyBelongsToItsEndpoint(text: String, language: Language) throws {
    let result = try one(text, language: language)
    let end = try #require(result.end)
    #expect(result.issues.isEmpty)
    #expect(result.start[.day] == 22)
    #expect(!result.start.isCertain(component: .hour))
    #expect(end[.month] == 12)
    #expect(end[.day] == 26)
    #expect(end[.hour] == 15)
    #expect(end[.minute] == 30)
  }

  @Test(arguments: ["Monday UTC to Friday last week", "Monday to Friday last week UTC"])
  func sharedZoneAtAWeekBoundary(text: String) throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))
    calendar.firstWeekday = 2
    calendar.minimumDaysInFirstWeek = 4
    let now = try #require(
      calendar.date(from: DateComponents(year: 2026, month: 1, day: 5, hour: 1)))
    let results = try Chrono().parse(
      text: text, refDate: now, calendar: calendar, languages: [.english])
    try #require(results.count == 1)
    let result = try #require(results.first)
    let end = try #require(result.end)
    #expect(result.text == text)
    #expect(result.issues.isEmpty)
    #expect(result.start[.year] == 2025)
    #expect(result.start[.month] == 12)
    #expect(result.start[.day] == 22)
    #expect(end[.day] == 26)
    #expect(result.start.resolvedCalendar.timeZone.secondsFromGMT() == 0)
    #expect(end.resolvedCalendar.timeZone.secondsFromGMT() == 0)
  }

  @Test("An inherited year must not normalize an impossible leap date")
  func invalidLeapDate() throws {
    let result = try one("December 2024 to February 29", language: .english)
    #expect(!result.issues.isEmpty)
  }

  @Test(arguments: ["December 2023 to February 29", "December 2023 to 29 February"])
  func aSuppliedYearCanResolveAnOmittedLeapYear(text: String) throws {
    let result = try one(text, language: .english)
    let end = try #require(result.end)
    #expect(result.issues.isEmpty)
    #expect(end[.year] == 2024)
    #expect(end[.month] == 2)
    #expect(end[.day] == 29)
    #expect(end.dateResolution.bounds != nil)
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
