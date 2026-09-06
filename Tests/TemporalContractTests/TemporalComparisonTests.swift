import Foundation
import Testing

@testable import SwiftyChrono

@Suite("Temporal comparison operands and scope")
struct TemporalComparisonTests {
  @Test(arguments: [
    ("before Monday", Language.english, TemporalComparison.before),
    ("after last week", .english, .after), ("since yesterday", .english, .since),
    ("through Monday", .english, .through),
    ("avant lundi", .french, .before), ("après lundi", .french, .after),
    ("depuis hier", .french, .since),
    ("vor Montag", .german, .before), ("nach Montag", .german, .after),
    ("seit gestern", .german, .since),
    ("antes de lunes", .spanish, .before), ("después de lunes", .spanish, .after),
    ("desde ayer", .spanish, .since),
    ("abans de dilluns", .catalan, .before), ("després de dilluns", .catalan, .after),
    ("des de ahir", .catalan, .since),
    ("до понедельника", .russian, .before), ("после понедельника", .russian, .after),
    ("2026年1月5日より前", .japanese, .before),
    ("2026年1月5日以降", .japanese, .since),
    ("2026年1月5日之前", .chineseSimplified, .before),
    ("2026年1月5日之後", .chinese, .after),
  ])
  func wholeOperands(text: String, language: Language, comparison: TemporalComparison) throws {
    let result = try one(text, language: language)
    #expect(result.issues.isEmpty)
    #expect(result.comparison == comparison)
    #expect(result.comparisonScope == nil)
    #expect(result.languages.contains(language))
  }

  @Test(arguments: [
    ("Monday before 3pm", Language.english, TemporalComparison.before),
    ("Monday after 3pm", .english, .after), ("Monday since 3pm", .english, .since),
    ("Monday through 3pm", .english, .through),
    ("Montag vor 15:00", .german, .before), ("Montag nach 15:00", .german, .after),
    ("понедельник после 15:00", .russian, .after),
    ("понедельник до 15:00", .russian, .before),
    ("lundi avant 15:00", .french, .before), ("lundi après 15:00", .french, .after),
    ("lunes antes de las 15:00", .spanish, .before),
    ("lunes después de las 15:00", .spanish, .after),
    ("lunes desde las 15:00", .spanish, .since),
    ("dilluns abans de les 15:00", .catalan, .before),
    ("dilluns després de les 15:00", .catalan, .after),
    ("dilluns des de les 15:00", .catalan, .since),
  ])
  func writtenDayScope(text: String, language: Language, comparison: TemporalComparison) throws {
    let result = try one(text, language: language)
    #expect(result.issues.isEmpty)
    #expect(result.comparison == comparison)
    let scope = try #require(result.comparisonScope)
    #expect(!scope.isCertain(component: .hour))
    #expect(scope[.day] == result.start[.day])
    #expect(result.start[.hour] == 15)
    #expect(result.end == nil)
  }

  @Test(arguments: [
    "before after Monday", "until Monday", "3pm before Monday",
    "Monday until 3pm", "last week after 3pm", "January after 3pm",
    "Monday to Friday after 3pm", "before Monday after 3pm",
    "Monday before 3pm to 5pm", "Monday before after 3pm",
  ])
  func unresolvedCannotLeakFragments(text: String) throws {
    let result = try one(text, language: .english)
    #expect(!result.issues.isEmpty)
  }

  @Test("Bare from does not turn a date period into an open-ended range")
  func ordinaryDateContext() throws {
    let result = try #require(parse("meeting notes from last week", language: .english).first)
    #expect(result.comparison == nil)
    #expect(result.text == "last week")
  }

  @Test("Neutral dates retain the modifier's actual language")
  func neutralDateAndSourceOffsets() throws {
    let source = "📚 notes before 2026-01-05"
    let results = try parse(source, language: .english)
    try #require(results.count == 1)
    let result = try #require(results.first)
    #expect(result.text == "before 2026-01-05")
    #expect(result.index == "📚 notes ".utf16.count)
    #expect(result.languages == [.neutral, .english])
    #expect(result.comparison == .before)
  }

  @Test("A written clock zone also supplies the day comparison's calendar")
  func sharedDayZone() throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))
    let now = try #require(
      calendar.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 1)))
    let text = "today after 3pm UTC"
    let results = try Chrono().parse(
      text: text, refDate: now, calendar: calendar, languages: [.english])
    try #require(results.count == 1)
    let result = try #require(results.first)
    let scope = try #require(result.comparisonScope)
    #expect(result.issues.isEmpty)
    #expect(result.text == text)
    #expect(scope[.year] == 2025)
    #expect(scope[.month] == 12)
    #expect(scope[.day] == 31)
    #expect(scope.resolvedCalendar.timeZone.secondsFromGMT() == 0)
    #expect(result.start.resolvedCalendar.timeZone == scope.resolvedCalendar.timeZone)
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
