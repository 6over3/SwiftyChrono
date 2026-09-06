import Foundation
import Testing

@testable import SwiftyChrono

@Suite("Relative clock identity")
struct RelativeClockTests {
  @Test(arguments: [("in 1 hour", 5, 6), ("1 hour ago", 6, 5)])
  func computedOffsetKeepsItsOccurrence(text: String, referenceHour: Int, expectedHour: Int) throws
  {
    let (calendar, reference) = try context(utcHour: referenceHour)
    let results = try Chrono().parse(
      text: text, refDate: reference, calendar: calendar, languages: [.english])
    try #require(results.count == 1)
    let result = try #require(results.first)
    guard case .unique(let date) = result.start.dateResolution else {
      Issue.record("An offset from a known instant must not become an ambiguous wall clock")
      return
    }
    let expected = try context(utcHour: expectedHour).1
    #expect(date.instant == expected)
  }

  @Test("A rolling range retains its actual end during a repeated hour")
  func rollingEnd() throws {
    let (calendar, reference) = try context(utcHour: 6)
    let result = try #require(
      Chrono().parse(
        text: "past 2 hours", refDate: reference,
        calendar: calendar, languages: [.english]
      ).first)
    let end = try #require(result.end)
    guard case .unique(let date) = end.dateResolution else {
      Issue.record("The captured end instant must not gain a second occurrence")
      return
    }
    #expect(date.instant == reference.addingTimeInterval(-1))
  }

  @Test("A written ambiguous clock still preserves both occurrences")
  func writtenClockRemainsAmbiguous() throws {
    let (calendar, reference) = try context(utcHour: 6)
    let result = try #require(
      Chrono().parse(
        text: "2026-11-01T01:30", refDate: reference,
        calendar: calendar, languages: [.neutral]
      ).first)
    guard case .repeated(let earlier, let later) = result.start.dateResolution else {
      Issue.record("A written civil time must not inherit certainty from the reference instant")
      return
    }
    let expectedEarlier = try context(utcHour: 5).1
    #expect(earlier.instant == expectedEarlier)
    #expect(later.instant == reference)
  }

  @Test("A later written clock or zone invalidates a computed instant")
  func changedFieldsDoNotKeepComputedIdentity() throws {
    let (calendar, reference) = try context(utcHour: 5)
    let result = try #require(
      Chrono().parse(
        text: "in 1 hour", refDate: reference,
        calendar: calendar, languages: [.english]
      ).first)
    var clock = result.start
    clock.assign(.minute, value: 45)
    guard case .repeated = clock.dateResolution else {
      Issue.record("An explicitly changed wall clock must be resolved again")
      return
    }
    var zoned = result.start
    zoned.assign(timeZone: try #require(TimeZone(secondsFromGMT: 0)))
    guard case .unique(let date) = zoned.dateResolution else {
      Issue.record("A numeric offset must resolve the written civil fields")
      return
    }
    let expected = try context(utcHour: 1).1
    #expect(date.instant == expected)
    #expect(result.start[.minute] == 30)
    #expect(!result.start.isCertain(component: .minute))
  }

  @Test(
    "A deadline covers the intervening time; an offset names its destination",
    arguments: [
      ("within two hours", "in two hours", Language.english),
      ("innerhalb von zwei Stunden", "in zwei Stunden", .german),
    ])
  func deadlineAndOffset(deadline: String, offset: String, language: Language) throws {
    let (calendar, reference) = try context(utcHour: 5)
    let range = try #require(
      Chrono().parse(
        text: deadline, refDate: reference,
        calendar: calendar, languages: [language]
      ).first)
    let destination = try #require(
      Chrono().parse(
        text: offset, refDate: reference,
        calendar: calendar, languages: [language]
      ).first)
    let end = try #require(range.end)
    guard case .unique(let startDate) = range.start.dateResolution,
      case .unique(let endDate) = end.dateResolution,
      case .unique(let destinationDate) = destination.start.dateResolution
    else {
      Issue.record("Relative deadline and offset endpoints must retain their computed identity")
      return
    }
    #expect(range.text == deadline)
    #expect(startDate.instant == reference)
    #expect(endDate.instant == reference.addingTimeInterval(7_199))
    #expect(destination.end == nil)
    #expect(destinationDate.instant == reference.addingTimeInterval(7_200))
  }

  @Test(arguments: ["within 0 hours", "within half a month", "within 999999999999999999999 hours"])
  func invalidDeadlineStaysWhole(text: String) throws {
    let (calendar, reference) = try context(utcHour: 5)
    let values = try Chrono().parse(
      text: text, refDate: reference,
      calendar: calendar, languages: [.english])
    try #require(values.count == 1)
    let value = try #require(values.first)
    #expect(value.text == text)
    #expect(!value.issues.isEmpty)
  }

  private func context(utcHour: Int) throws -> (Calendar, Date) {
    var utc = Calendar(identifier: .gregorian)
    utc.timeZone = try #require(TimeZone(secondsFromGMT: 0))
    let reference = try #require(
      utc.date(from: DateComponents(year: 2026, month: 11, day: 1, hour: utcHour, minute: 30)))
    var calendar = utc
    calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
    return (calendar, reference)
  }
}
