import Foundation
import Testing

@testable import SwiftyChrono

@Suite("Relative calendar and rolling periods")
struct RelativePeriodTests {
  @Test(arguments: [
    ("last week", Language.english), ("semana pasada", .spanish),
    ("setmana passada", .catalan), ("semaine dernière", .french),
    ("letzte Woche", .german), ("先週", .japanese),
    ("上周", .chineseSimplified), ("上週", .chinese), ("прошлая неделя", .russian),
  ])
  func previousWeek(text: String, language: Language) throws {
    let calendar = try calendar()
    let results = try parse(text, language: language, calendar: calendar)
    try #require(results.count == 1)
    let value = try #require(results.first)
    #expect(value.issues.isEmpty)
    #expect(value.start[.year] == 2026)
    #expect(value.start[.month] == 8)
    #expect(value.start[.day] == 24)
    #expect(value.end?[.month] == 8)
    #expect(value.end?[.day] == 30)
    #expect(value.text == text)
    #expect(value.languages == [language])
  }

  @Test(arguments: [
    ("past two weeks", Language.english), ("últimas dos semanas", .spanish),
    ("últimes dues setmanes", .catalan), ("2 dernières semaines", .french),
    ("letzte zwei Wochen", .german), ("過去2週間", .japanese),
    ("过去两周", .chineseSimplified), ("過去兩週", .chinese), ("последние две недели", .russian),
  ])
  func rollingWeeks(text: String, language: Language) throws {
    let calendar = try calendar()
    let values = try parse(text, language: language, calendar: calendar)
    try #require(values.count == 1)
    let value = try #require(values.first)
    #expect(value.issues.isEmpty)
    #expect(value.start[.day] == 20)
    #expect(value.start[.month] == 8)
    #expect(value.start[.hour] == 15)
    #expect(value.start[.minute] == 30)
    #expect(value.start.isCertain(component: .second))
    #expect(value.end?[.day] == 3)
    #expect(value.end?[.month] == 9)
    #expect(value.end?[.minute] == 29)
    #expect(value.end?[.second] == 59)
  }

  @Test(arguments: [
    "past 0 weeks", "past 999999999999999999999999 weeks", "this 2 weeks", "past half month",
  ])
  func invalidAmounts(text: String) throws {
    let values = try parse(text, language: .english, calendar: calendar())
    try #require(values.count == 1)
    let value = try #require(values.first)
    #expect(value.text == text)
    #expect(!value.issues.isEmpty)
  }

  @Test("Current and next periods honor the supplied calendar's week start")
  func weekConvention() throws {
    var calendar = try calendar()
    calendar.firstWeekday = 1
    for (text, start, end) in [("this week", 30, 5), ("next week", 6, 12)] {
      let value = try #require(parse(text, language: .english, calendar: calendar).first)
      #expect(value.start[.day] == start)
      #expect(value.end?[.day] == end)
    }
  }

  @Test(
    "Previous calendar months include the leap day in every admitted language",
    arguments: [
      ("last month", Language.english), ("mes pasado", .spanish),
      ("mes passat", .catalan), ("mois dernier", .french), ("letzter Monat", .german),
      ("先月", .japanese), ("上个月", .chineseSimplified), ("上個月", .chinese),
      ("прошлый месяц", .russian),
    ])
  func leapMonth(text: String, language: Language) throws {
    let calendar = try calendar()
    let reference = try #require(
      calendar.date(from: DateComponents(year: 2024, month: 3, day: 31, hour: 15)))
    let results = try Chrono().parse(
      text: text, refDate: reference, calendar: calendar, languages: [language])
    try #require(results.count == 1)
    let value = try #require(results.first)
    #expect(value.issues.isEmpty)
    #expect(value.text == text)
    #expect(value.start[.year] == 2024)
    #expect(value.start[.month] == 2)
    #expect(value.start[.day] == 1)
    #expect(value.end?[.month] == 2)
    #expect(value.end?[.day] == 29)
  }

  @Test(
    "Clock units, native number words, and suffixes retain the requested duration",
    arguments: [
      ("past two seconds", Language.english, 2),
      ("últimos dos segundos", .spanish, 2), ("últims dos segons", .catalan, 2),
      ("deux dernières secondes", .french, 2), ("letzte zwei Sekunden", .german, 2),
      ("過去二秒間", .japanese, 2), ("过去两秒钟", .chineseSimplified, 2),
      ("過去兩秒鐘", .chinese, 2), ("последние две секунды", .russian, 2),
      ("past half an hour", .english, 1_800), ("過去半時間", .japanese, 1_800),
      ("过去半小时", .chineseSimplified, 1_800), ("過去半小時", .chinese, 1_800),
    ])
  func clockUnits(text: String, language: Language, duration: Int) throws {
    let results = try parse(text, language: language, calendar: calendar())
    try #require(results.count == 1)
    let value = try #require(results.first)
    let end = try #require(value.end)
    guard case .unique(let first) = value.start.dateResolution,
      case .unique(let last) = end.dateResolution
    else {
      Issue.record("Computed endpoints must resolve to unique instants")
      return
    }
    #expect(value.text == text)
    #expect(value.issues.isEmpty)
    #expect(last.instant.timeIntervalSince(first.instant) + 1 == TimeInterval(duration))
  }

  private func calendar() throws -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))
    calendar.firstWeekday = 2
    calendar.minimumDaysInFirstWeek = 4
    return calendar
  }

  private func parse(_ text: String, language: Language, calendar: Calendar) throws
    -> [ParsedResult]
  {
    let now = try #require(
      calendar.date(from: DateComponents(year: 2026, month: 9, day: 3, hour: 15, minute: 30)))
    return try Chrono().parse(text: text, refDate: now, calendar: calendar, languages: [language])
  }
}
