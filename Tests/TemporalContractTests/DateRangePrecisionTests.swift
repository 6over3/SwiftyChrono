import Foundation
import Testing

@testable import SwiftyChrono

@Suite("Independent range endpoint precision")
struct DateRangePrecisionTests {
  @Test(arguments: [
    ("to", Language.english), ("à", .french), ("bis", .german), ("до", .russian),
  ])
  func dayAndClock(joiner: String, language: Language) throws {
    let result = try one("2026-01-01 \(joiner) 2026-01-03T15:30", language: language)
    let end = try #require(result.end)
    #expect(result.start.isCertain(component: .day))
    #expect(!result.start.isCertain(component: .hour))
    #expect(!result.start.isCertain(component: .minute))
    #expect(end.isCertain(component: .minute))
    #expect(!end.isCertain(component: .second))
    #expect(result.start[.day] == 1)
    #expect(end[.day] == 3)
  }

  @Test("A second-precision endpoint does not change a minute-precision endpoint")
  func distinctClockPrecision() throws {
    let result = try one("2026-01-01T10:15 to 2026-01-01T11:45:30", language: .english)
    let end = try #require(result.end)
    #expect(result.start.isCertain(component: .minute))
    #expect(!result.start.isCertain(component: .second))
    #expect(end.isCertain(component: .second))
    #expect(result.start[.minute] == 15)
    #expect(end[.second] == 30)
  }

  @Test("A month can inherit a year without acquiring a day")
  func monthRetainsItsPrecision() throws {
    let result = try one("January to March 5, 2027", language: .english)
    let end = try #require(result.end)
    #expect(result.start.isCertain(component: .month))
    #expect(result.start[.year] == 2027)
    #expect(!result.start.isCertain(component: .day))
    #expect(result.start[.month] == 1)
    #expect(end.isCertain(component: .day))
    #expect(end[.day] == 5)
  }

  @Test(
    "An omitted clock date inherits the written date without altering either clock",
    arguments: [("to", Language.english), ("à", .french), ("bis", .german), ("до", .russian)])
  func omittedDateContext(joiner: String, language: Language) throws {
    let result = try one("10:15 \(joiner) 2026-01-02T15:30", language: language)
    let end = try #require(result.end)
    #expect(result.start[.day] == 2)
    #expect(result.start[.month] == 1)
    #expect(result.start[.year] == 2026)
    #expect(result.start[.hour] == 10)
    #expect(result.start[.minute] == 15)
    #expect(end[.hour] == 15)
    #expect(end[.minute] == 30)
  }

  private func one(_ text: String, language: Language, issues: [ParsedDateIssue] = []) throws
    -> ParsedResult
  {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
    let reference = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 6)))
    let results = try Chrono().parse(
      text: text, refDate: reference, calendar: calendar, languages: [language])
    try #require(results.count == 1)
    let result = try #require(results.first)
    #expect(result.text == text)
    #expect(result.issues == issues)
    return result
  }

  @Test("A qualifier without date precision cannot acquire a year from another endpoint")
  func unresolvedQualifierDoesNotBecomeAYear() throws {
    let result = try one("morning to now", language: .english, issues: [.unresolvedDayPeriod])
    #expect(result.start.knownValues.isEmpty)
    let end = try #require(result.end)
    #expect(end.isCertain(component: .second))
  }
}
