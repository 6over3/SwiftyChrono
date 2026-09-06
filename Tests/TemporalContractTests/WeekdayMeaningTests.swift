import Foundation
import Testing

@testable import SwiftyChrono

@Suite("Weekday occurrences and named weeks")
struct WeekdayMeaningTests {
  @Test(arguments: [
    ("last Monday", Language.english), ("letzten Montag", .german),
    ("lundi dernier", .french), ("pasado lunes", .spanish),
    ("passat dilluns", .catalan), ("прошлый понедельник", .russian),
    ("lunes pasado", .spanish), ("dilluns passat", .catalan),
  ])
  func previousOccurrenceIsNotAlwaysPreviousWeek(text: String, language: Language) throws {
    let result = try parse(text, language: language, referenceDay: 2)
    #expect(result.issues.isEmpty)
    #expect(result.start[.year] == 2025)
    #expect(result.start[.month] == 12)
    #expect(result.start[.day] == 29)
  }

  @Test(arguments: [
    ("next Saturday", Language.english), ("nächsten Samstag", .german),
    ("samedi prochain", .french), ("próximo sábado", .spanish),
    ("proper dissabte", .catalan), ("следующая суббота", .russian),
  ])
  func nextOccurrenceCanBeWithinTheCurrentWeek(text: String, language: Language) throws {
    let result = try parse(text, language: language, referenceDay: 2)
    #expect(result.issues.isEmpty)
    #expect(result.start[.day] == 3)
    #expect(result.start[.month] == 1)
  }

  @Test(arguments: [("last Monday", 29, 12, 2025), ("next Monday", 12, 1, 2026)])
  func anExplicitDirectionExcludesToday(text: String, day: Int, month: Int, year: Int) throws {
    let result = try parse(text, language: .english, referenceDay: 5)
    #expect(result.issues.isEmpty)
    #expect(result.start[.day] == day)
    #expect(result.start[.month] == month)
    #expect(result.start[.year] == year)
  }

  @Test(arguments: [
    ("Monday last week", Language.english), ("Montag letzte Woche", .german),
    ("lunes pasada semana", .spanish), ("dilluns passada setmana", .catalan),
    ("понедельник прошлой недели", .russian), ("上周一", .chineseSimplified), ("上週一", .chinese),
    ("lunes de la semana pasada", .spanish), ("dilluns de la setmana passada", .catalan),
    ("lundi de la semaine dernière", .french), ("letzte Woche Montag", .german),
  ])
  func namedWeeksRespectFirstWeekday(text: String, language: Language) throws {
    let mondayWeek = try parse(text, language: language, referenceDay: 4, firstWeekday: 2)
    let sundayWeek = try parse(text, language: language, referenceDay: 4, firstWeekday: 1)
    #expect(mondayWeek.issues.isEmpty)
    #expect(sundayWeek.issues.isEmpty)
    #expect(mondayWeek.start[.day] == 22)
    #expect(sundayWeek.start[.day] == 29)
    #expect(mondayWeek.start[.month] == 12)
    #expect(sundayWeek.start[.month] == 12)
  }

  @Test(arguments: ["next Monday last week", "last Monday next week"])
  func conflictingModifiersRetainTheWholeExpression(text: String) throws {
    let result = try parse(text, language: .english, referenceDay: 2)
    #expect(!result.issues.isEmpty)
  }

  @Test("Weekday lookup uses real calendar dates across a skipped civil day")
  func skippedDay() throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(identifier: "Pacific/Apia"))
    calendar.firstWeekday = 2
    let reference = try #require(
      calendar.date(from: DateComponents(year: 2011, month: 12, day: 31, hour: 15)))
    let ref = ChronoDate(instant: reference, calendar: calendar)
    let previous = try WeekdayReference.previousOccurrence.date(for: 5, relativeTo: ref)
    #expect(previous.year == 2011)
    #expect(previous.month == 12)
    #expect(previous.day == 23)
    let current = try WeekdayReference.currentWeek.date(for: 6, relativeTo: ref)
    #expect(current.day == 31)
    #expect(throws: ChronoError.invalidDate) {
      try WeekdayReference.currentWeek.date(for: 5, relativeTo: ref)
    }
  }

  @Test(arguments: Array(1...7))
  func everyWeekStartContainsItsResolvedWeekdays(firstWeekday: Int) throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
    calendar.firstWeekday = firstWeekday
    let reference = try #require(
      calendar.date(from: DateComponents(year: 2026, month: 1, day: 4, hour: 15)))
    let week = try #require(calendar.dateInterval(of: .weekOfYear, for: reference))
    let ref = ChronoDate(instant: reference, calendar: calendar)
    for weekday in 0...6 {
      let date = try WeekdayReference.currentWeek.date(for: weekday, relativeTo: ref)
      #expect(date.instant >= week.start && date.instant < week.end)
      #expect(date.weekday == weekday)
    }
  }

  @Test(arguments: [("dl.", Language.catalan), ("пн.", .russian)])
  func abbreviationPunctuationIsLiteral(text: String, language: Language) throws {
    let result = try parse(text, language: language, referenceDay: 2)
    #expect(result.issues.isEmpty)
    #expect(result.start[.weekday] == 1)
  }

  private func parse(
    _ text: String, language: Language, referenceDay: Int, firstWeekday: Int = 2
  ) throws -> ParsedResult {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
    calendar.firstWeekday = firstWeekday
    calendar.minimumDaysInFirstWeek = 4
    let reference = try #require(
      calendar.date(from: DateComponents(year: 2026, month: 1, day: referenceDay, hour: 15)))
    let results = try Chrono().parse(
      text: text, refDate: reference, calendar: calendar, languages: [language])
    try #require(results.count == 1)
    let result = try #require(results.first)
    #expect(result.text == text)
    return result
  }
}
