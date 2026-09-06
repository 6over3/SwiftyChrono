import Foundation
import Testing

@testable import SwiftyChrono

@Suite("Written time zone binding")
struct TimeZoneBindingTests {
  @Test(arguments: ["2026-01-01T15:30 CST", "2026-01-01T15:30 IST"])
  func abbreviationDoesNotGuess(text: String) throws {
    let result = try one(text)
    #expect(result.text == text)
    #expect(result.issues.contains(.invalidTimeZone))
  }

  @Test(arguments: [
    ("2026-01-01T15:30 UTC", 15), ("2026-01-01T15:30 GMT", 15),
    ("2026-01-01T15:30 Asia/Tokyo", 6), ("2026-01-01T15:30 (Asia/Tokyo)", 6),
  ])
  func absoluteZones(text: String, utcHour: Int) throws {
    let result = try one(text)
    #expect(result.text == text)
    #expect(result.issues.isEmpty)
    guard case .unique(let date) = result.start.dateResolution else {
      Issue.record("A definite zone should resolve the complete written time")
      return
    }
    let expected = try instant(year: 2026, month: 1, day: 1, hour: utcHour, minute: 30)
    #expect(date.instant == expected)
  }

  @Test(arguments: [(2013, 11), (2026, 12)])
  func namedZoneUsesRulesForTheWrittenDate(year: Int, utcHour: Int) throws {
    let result = try one("\(year)-01-01T15:30 Europe/Moscow")
    #expect(result.issues.isEmpty)
    guard case .unique(let date) = result.start.dateResolution else {
      Issue.record("A named zone must resolve using rules for the written date")
      return
    }
    let expected = try instant(year: year, month: 1, day: 1, hour: utcHour, minute: 30)
    #expect(date.instant == expected)
  }

  @Test(arguments: ["tomorrow UTC", "tomorrow UTC+00:00", "tomorrow Etc/UTC"])
  func relativeDayUsesWrittenZone(text: String) throws {
    let result = try one(text)
    #expect(result.text == text)
    #expect(result.issues.isEmpty)
    #expect(result.start[.day] == 2)
    #expect(result.start[.month] == 1)
  }

  @Test(arguments: [
    ("mañana UTC", Language.spanish), ("demà UTC", .catalan),
    ("demain UTC", .french), ("morgen UTC", .german), ("明日 UTC", .japanese),
    ("明天 UTC", .chineseSimplified), ("明天 UTC", .chinese), ("завтра UTC", .russian),
  ])
  func localizedRelativeDays(text: String, language: Language) throws {
    let result = try one(text, language: language)
    #expect(result.text == text)
    #expect(result.issues.isEmpty)
    #expect(result.start[.day] == 2)
  }

  @Test("A zone on a clock applies before computing its relative date")
  func composedRelativeDay() throws {
    let result = try one("tomorrow at 3pm UTC")
    #expect(result.text == "tomorrow at 3pm UTC")
    #expect(result.issues.isEmpty)
    guard case .unique(let date) = result.start.dateResolution else {
      Issue.record("The combined relative date and clock must use one written zone")
      return
    }
    let expected = try instant(year: 2026, month: 1, day: 2, hour: 15, minute: 0)
    #expect(date.instant == expected)
  }

  @Test(arguments: [
    "2026-01-01T15:30 UTC+00:99", "2026-01-01T15:30 +2460",
    "2026-01-01T15:30 (UTC", "2026-01-01T15:30 Asia/Not_A_Zone",
    "2026-01-01T15:30+09:00 UTC",
  ])
  func malformedOrConflictingZoneStaysWhole(text: String) throws {
    let result = try one(text)
    #expect(result.text == text)
    #expect(result.issues.contains(.invalidTimeZone))
  }

  @Test(arguments: [
    ("2026-01-01T10:00+09:00 to 2026-01-01T03:00+00:00", 1, 3),
    ("2026-01-01T10:00 to 2026-01-01T12:00 UTC", 10, 12),
  ])
  func rangeEndpointZones(text: String, startHour: Int, endHour: Int) throws {
    let result = try one(text)
    let endpoint = try #require(result.end)
    #expect(result.text == text)
    #expect(result.issues.isEmpty)
    guard case .unique(let start) = result.start.dateResolution,
      case .unique(let end) = endpoint.dateResolution
    else {
      Issue.record("Written endpoint zones must resolve without being overwritten")
      return
    }
    let expectedStart = try instant(year: 2026, month: 1, day: 1, hour: startHour, minute: 0)
    let expectedEnd = try instant(year: 2026, month: 1, day: 1, hour: endHour, minute: 0)
    #expect(start.instant == expectedStart)
    #expect(end.instant == expectedEnd)
  }

  @Test("Calculated periods retain exact instants after binding a zone")
  func rollingRange() throws {
    let result = try one("past two hours UTC")
    let endpoint = try #require(result.end)
    #expect(result.issues.isEmpty)
    guard case .unique(let start) = result.start.dateResolution,
      case .unique(let end) = endpoint.dateResolution
    else {
      Issue.record("Zone binding must recalculate relative endpoints")
      return
    }
    let expectedStart = try instant(year: 2026, month: 1, day: 1, hour: 16, minute: 30)
    #expect(start.instant == expectedStart)
    #expect(end.instant == expectedStart.addingTimeInterval(7_199))
  }

  @Test("Zone composition retains the original Unicode source range")
  func sourceRange() throws {
    let text = "👩🏽‍💻 tomorrow at 3pm UTC and notes"
    let result = try one(text)
    let range = try #require(
      Range(NSRange(location: result.index, length: result.text.utf16.count), in: text))
    #expect(String(text[range]) == "tomorrow at 3pm UTC")
    #expect(result.issues.isEmpty)
  }

  @Test("Conflicting date and clock zones do not discard either constraint")
  func conflictingOperandZones() throws {
    let text = "tomorrow UTC at 3pm Asia/Tokyo"
    let result = try one(text)
    #expect(result.text == text)
    #expect(result.issues.contains(.invalidTimeZone))
  }

  @Test("A relative date is resolved before joining a differently zoned endpoint")
  func composedRelativeRange() throws {
    let result = try one("tomorrow at 3pm UTC to 2026-01-03T16:00+09:00")
    let endpoint = try #require(result.end)
    #expect(result.issues.isEmpty)
    guard case .unique(let start) = result.start.dateResolution,
      case .unique(let end) = endpoint.dateResolution
    else {
      Issue.record("Each composed endpoint must use its own written zone")
      return
    }
    let expectedStart = try instant(year: 2026, month: 1, day: 2, hour: 15, minute: 0)
    let expectedEnd = try instant(year: 2026, month: 1, day: 3, hour: 7, minute: 0)
    #expect(start.instant == expectedStart)
    #expect(end.instant == expectedEnd)
  }

  private func one(_ text: String, language: Language = .english) throws -> ParsedResult {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))
    // January 2 in Tokyo but still January 1 in UTC.
    let reference = try instant(year: 2026, month: 1, day: 1, hour: 18, minute: 30)
    let values = try Chrono().parse(
      text: text, refDate: reference, calendar: calendar, languages: [language])
    try #require(values.count == 1)
    return try #require(values.first)
  }

  private func instant(year: Int, month: Int, day: Int, hour: Int, minute: Int) throws -> Date {
    var utc = Calendar(identifier: .gregorian)
    utc.timeZone = try #require(TimeZone(secondsFromGMT: 0))
    return try #require(
      utc.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))
    )
  }
}
