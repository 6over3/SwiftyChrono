import Foundation
import Testing

@testable import SwiftyChrono

@Suite("Captured current instant")
struct CurrentInstantTests {
  static let expressions: [(String, Language)] = [
    ("now", .english), ("ahora", .spanish), ("ara", .catalan),
    ("maintenant", .french), ("jetzt", .german), ("сейчас", .russian),
    ("现在", .chineseSimplified), ("而家", .chinese),
  ]

  @Test(arguments: expressions, [5, 6])
  func retainsTheCapturedOccurrence(expression: (String, Language), utcHour: Int) throws {
    let (calendar, reference) = try context(utcHour: utcHour)
    let result = try one(
      expression.0, language: expression.1, calendar: calendar, reference: reference)
    #expect(result.issues.isEmpty)
    #expect(result.text == expression.0)
    #expect(result.start.isCertain(component: .second))
    #expect(!result.start.isCertain(component: .millisecond))
    guard case .unique(let date) = result.start.dateResolution else {
      Issue.record("The current instant must not become a repeated civil clock")
      return
    }
    #expect(date.instant == reference)
    #expect(result.end == nil)
  }

  @Test(arguments: ["UTC", "Asia/Tokyo", "America/New_York"])
  func aWrittenZoneChangesTheClockNotTheInstant(zone: String) throws {
    let (calendar, reference) = try context(utcHour: 6)
    let text = "now \(zone)"
    let result = try one(text, language: .english, calendar: calendar, reference: reference)
    #expect(result.text == text)
    #expect(result.issues.isEmpty)
    guard case .unique(let date) = result.start.dateResolution else {
      Issue.record("A zone must not turn a captured instant into an ambiguous clock")
      return
    }
    #expect(date.instant == reference)
    #expect(date.calendar.timeZone == TimeZone(identifier: zone))
  }

  @Test(arguments: ["CST", "+00:99", "Asia/Not_A_Zone"])
  func unresolvedZoneDoesNotExposeAPartialInstant(zone: String) throws {
    let (calendar, reference) = try context(utcHour: 6)
    let text = "now \(zone)"
    let result = try one(text, language: .english, calendar: calendar, reference: reference)
    #expect(result.text == text)
    #expect(result.issues.contains(.invalidTimeZone))
  }

  @Test("The operand's complete Unicode source is retained")
  func sourceRange() throws {
    let (calendar, reference) = try context(utcHour: 6)
    let text = "👩🏽‍💻 notes now UTC"
    let result = try one(text, language: .english, calendar: calendar, reference: reference)
    let range = try #require(
      Range(NSRange(location: result.index, length: result.text.utf16.count), in: text))
    #expect(String(text[range]) == "now UTC")
  }

  @Test(arguments: ["yesterday to now", "now to tomorrow"])
  func rangeEndpointsRetainTheirOwnPrecision(text: String) throws {
    let (calendar, reference) = try context(utcHour: 6)
    let result = try one(text, language: .english, calendar: calendar, reference: reference)
    let end = try #require(result.end)
    #expect(result.text == text)
    #expect(result.issues.isEmpty)
    let current = text.hasPrefix("now") ? result.start : end
    let day = text.hasPrefix("now") ? end : result.start
    #expect(current.isCertain(component: .second))
    #expect(day.isCertain(component: .day))
    #expect(!day.isCertain(component: .hour))
    #expect(!day.isCertain(component: .minute))
    #expect(!day.isCertain(component: .second))
    guard case .unique(let date) = current.dateResolution else {
      Issue.record("Range composition must retain the captured instant")
      return
    }
    #expect(date.instant == reference)
  }

  private func one(
    _ text: String, language: Language, calendar: Calendar, reference: Date
  ) throws -> ParsedResult {
    let results = try Chrono().parse(
      text: text, refDate: reference, calendar: calendar, languages: [language])
    try #require(results.count == 1)
    return try #require(results.first)
  }

  private func context(utcHour: Int) throws -> (Calendar, Date) {
    var utc = Calendar(identifier: .gregorian)
    utc.timeZone = try #require(TimeZone(secondsFromGMT: 0))
    let reference = try #require(
      utc.date(from: DateComponents(year: 2026, month: 11, day: 1, hour: utcHour, minute: 30))
    ).addingTimeInterval(0.25)
    var calendar = utc
    calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
    return (calendar, reference)
  }
}
