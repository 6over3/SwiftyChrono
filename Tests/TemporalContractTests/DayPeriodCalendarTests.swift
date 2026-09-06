import Foundation
import Testing

@testable import SwiftyChrono

@Suite("Day periods follow the civil calendar")
struct DayPeriodCalendarTests {
  @Test(arguments: [("2026-03-08 morning", 11), ("2026-11-01 morning", 13)])
  func daylightSavingChangesElapsedHours(text: String, hours: Int) throws {
    let result = try parse(text, zone: "America/New_York")
    #expect(result.issues.isEmpty)
    let interval = try interval(result)
    #expect(interval.duration == TimeInterval(hours * 3_600))
    #expect(result.start[.hour] == 0)
    #expect(result.end?[.hour] == 11)
  }

  @Test("A skipped midnight does not erase the rest of that morning")
  func skippedMidnight() throws {
    let result = try parse("2018-11-04 morning", zone: "America/Sao_Paulo")
    #expect(result.issues.isEmpty)
    #expect(try interval(result).duration == 11 * 3_600)
    #expect(result.start[.hour] == 1)
    #expect(result.end?[.hour] == 11)
  }

  @Test("A skipped civil date cannot become the following morning")
  func skippedDate() throws {
    let result = try parse("2011-12-30 morning", zone: "Pacific/Apia")
    #expect(result.issues == [.nonexistentLocalTime])
    #expect(result.end == nil)
    #expect(result.start[.day] == 30)
  }

  @Test("A written time zone supplies the relative date before choosing period boundaries")
  func writtenZone() throws {
    let result = try parse("this morning Asia/Tokyo", zone: "UTC")
    #expect(result.issues.isEmpty)
    #expect(result.start[.day] == 3)
    #expect(result.start[.hour] == 0)
    #expect(result.start.resolvedCalendar.timeZone.identifier == "Asia/Tokyo")
    #expect(try interval(result).duration == 12 * 3_600)
  }

  @Test(arguments: [("es_CO", 0), ("es_ES", 6)])
  func regionSpecificConventions(locale: String, hour: Int) throws {
    let result = try parse("ayer por la mañana", zone: "UTC", locale: locale, language: .spanish)
    #expect(result.issues.isEmpty)
    #expect(result.start[.hour] == hour)
    #expect(result.end?[.hour] == 11)
  }

  @Test("An invalid qualified clock does not roll its endpoint into another day")
  func conflictingRangeRetainsOriginalDate() throws {
    let result = try parse("今天上午15点到下午4点", zone: "UTC", language: .chineseSimplified)
    #expect(result.issues == [.invalidComponents])
    #expect(result.start[.day] == 2)
    #expect(result.end?[.day] == 2)
  }

  private func parse(
    _ text: String, zone: String, locale: String = "en_US_POSIX", language: Language = .english
  ) throws -> ParsedResult {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(identifier: zone))
    calendar.locale = Locale(identifier: locale)
    var utc = calendar
    utc.timeZone = try #require(TimeZone(secondsFromGMT: 0))
    let reference = try #require(
      utc.date(from: DateComponents(year: 2026, month: 1, day: 2, hour: 18)))
    let results = try Chrono().parse(
      text: text, refDate: reference, calendar: calendar, languages: [language])
    try #require(results.count == 1)
    let result = try #require(results.first)
    #expect(result.text == text)
    return result
  }

  private func interval(_ result: ParsedResult) throws -> DateInterval {
    let end = try #require(result.end)
    guard case .unique(let first) = result.start.dateResolution,
      case .unique(let last) = end.dateResolution
    else { throw ChronoError.invalidDate }
    return DateInterval(start: first.instant, end: last.instant.addingTimeInterval(1))
  }
}
