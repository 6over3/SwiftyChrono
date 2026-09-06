import Foundation
import Testing

@testable import SwiftyChrono

@Suite("Date-bound day periods")
struct DayPeriodTests {
  @Test(arguments: [
    ("this morning", Language.english, 2, 0, 12),
    ("yesterday morning", .english, 1, 0, 12),
    ("this afternoon", .english, 2, 12, 18),
    ("hier matin", .french, 1, 4, 12),
    ("hier soir", .french, 1, 18, 24),
    ("heute Morgen", .german, 2, 5, 10),
    ("heute Nachmittag", .german, 2, 13, 18),
    ("ayer por la mañana", .spanish, 1, 6, 12),
    ("ahir pel matí", .catalan, 1, 6, 12),
    ("сегодня утром", .russian, 2, 4, 12),
    ("今朝", .japanese, 2, 4, 12),
    ("今夕", .japanese, 2, 16, 19),
    ("今夜", .japanese, 2, 19, 23),
    ("今天上午", .chineseSimplified, 2, 8, 12),
    ("今天早上", .chineseSimplified, 2, 5, 8),
    ("今日下午", .chinese, 2, 13, 19),
  ])
  func anchoredPeriods(text: String, language: Language, day: Int, start: Int, end: Int) throws {
    let result = try one(text, language: language)
    #expect(result.issues.isEmpty)
    let endpoint = try #require(result.end)
    let first = try unique(result.start)
    let last = try unique(endpoint)
    #expect(first.day == day)
    #expect(first.hour == start)
    #expect(first.minute == 0)
    #expect(first.second == 0)
    #expect(last.day == day)
    #expect(last.hour == end - 1)
    #expect(last.minute == 59)
    #expect(last.second == 59)
  }

  @Test(arguments: [
    ("morning", Language.english), ("afternoon", .english),
    ("утром", .russian), ("上午", .chineseSimplified),
  ])
  func floatingPeriodsDoNotInventToday(text: String, language: Language) throws {
    let result = try one(text, language: language)
    #expect(!result.issues.isEmpty)
  }

  @Test(arguments: ["yesterday morning at 3pm", "tomorrow afternoon at 9am", "noon at 3pm"])
  func conflictingClockKeepsTheWholeExpression(text: String) throws {
    let result = try one(text, language: .english)
    #expect(!result.issues.isEmpty)
  }

  @Test(arguments: [("tomorrow afternoon at 3", 15), ("tomorrow morning at 10", 10)])
  func qualifierResolvesAnUnmarkedClock(text: String, hour: Int) throws {
    let result = try one(text, language: .english)
    #expect(result.issues.isEmpty)
    #expect(result.end == nil)
    let date = try unique(result.start)
    #expect(date.day == 3)
    #expect(date.hour == hour)
  }

  @Test("A range keeps the day part of each independently dated endpoint")
  func periodRange() throws {
    let result = try one("this morning to tomorrow evening", language: .english)
    #expect(result.issues.isEmpty)
    let start = try unique(result.start)
    let end = try unique(#require(result.end))
    #expect(start.day == 2)
    #expect(start.hour == 0)
    #expect(end.day == 3)
    #expect(end.hour == 20)
    #expect(end.minute == 59)
  }

  @Test(arguments: [
    ("今天下午3点", Language.chineseSimplified, 15),
    ("今天早上9点", .chineseSimplified, 9),
    ("今日下晝3點", .chinese, 15),
    ("今天下午15点", .chineseSimplified, 15),
  ])
  func writtenChineseClocksUseTheirMeridiem(text: String, language: Language, hour: Int) throws {
    let result = try one(text, language: language)
    #expect(result.issues.isEmpty)
    #expect(result.end == nil)
    #expect(try unique(result.start).hour == hour)
  }

  @Test(arguments: ["今天上午3点PM", "今天下午0点", "今天中午3点"])
  func contradictoryChineseClocksDoNotIgnoreTheirQualifier(text: String) throws {
    let result = try one(text, language: .chineseSimplified)
    #expect(result.issues == [.invalidComponents])
  }

  @Test(arguments: [
    ("at midnight", Language.english), ("à minuit", .french),
    ("um Mitternacht", .german), ("a medianoche", .spanish), ("a mitjanit", .catalan),
  ])
  func midnightDoesNotChooseADayBoundary(text: String, language: Language) throws {
    let result = try one(text, language: language)
    #expect(result.issues == [.unresolvedDayPeriod])
  }

  @Test(arguments: ["last week at 3pm", "last week morning"])
  func recurringClocksDoNotBecomeContinuousRanges(text: String) throws {
    let result = try one(text, language: .english)
    #expect(!result.issues.isEmpty)
  }

  @Test(arguments: [("3 утра", 3), ("3 вечера", 15), ("3 ночи", 3), ("23 ночи", 23)])
  func writtenRussianClocks(text: String, hour: Int) throws {
    let result = try one(text, language: .russian)
    #expect(result.issues.isEmpty)
    #expect(try unique(result.start).hour == hour)
  }

  @Test(arguments: [("3-4 вечера", 15, 16, 2), ("3 вечера-4 утра", 15, 4, 3)])
  func qualifiedClockRanges(text: String, start: Int, end: Int, endDay: Int) throws {
    let result = try one(text, language: .russian)
    #expect(result.issues.isEmpty)
    #expect(try unique(result.start).hour == start)
    let last = try unique(#require(result.end))
    #expect(last.hour == end)
    #expect(last.day == endDay)
  }

  @Test(arguments: [
    ("Monday morning", Language.english), ("Montag Morgen", .german),
    ("понедельник утром", .russian),
  ])
  func weekdayPeriodDoesNotUseTheReferenceDay(text: String, language: Language) throws {
    let result = try one(text, language: language)
    #expect(result.issues.isEmpty)
    let first = try unique(result.start)
    #expect(first.calendar.component(.weekday, from: first.instant) == 2)
    #expect(result.end != nil)
  }

  @Test(arguments: [
    ("at noon AM", Language.english), ("à midi AM", .french), ("a mediodia AM", .spanish),
  ])
  func noonCannotBeAM(text: String, language: Language) throws {
    let result = try one(text, language: language)
    #expect(result.issues == [.invalidComponents])
  }

  private func one(_ text: String, language: Language) throws -> ParsedResult {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
    let reference = try #require(
      calendar.date(from: DateComponents(year: 2026, month: 1, day: 2, hour: 15, minute: 30)))
    let results = try Chrono().parse(
      text: text, refDate: reference, calendar: calendar, languages: [language])
    try #require(results.count == 1)
    let result = try #require(results.first)
    #expect(result.text == text)
    return result
  }

  private func unique(_ components: ParsedComponents) throws -> ChronoDate {
    guard case .unique(let date) = components.dateResolution else {
      throw ChronoError.invalidDate
    }
    return date
  }
}
