import Foundation
import Testing

@testable import SwiftyChrono

@Suite("Chinese deadline windows and offsets")
struct ChineseDeadlineTests {
  @Test(arguments: [("两小时内", Language.chineseSimplified), ("兩小時內", .chinese)])
  func withinIncludesTheInterveningTime(text: String, language: Language) throws {
    let result = try parse(text, language: language)
    #expect(result.issues.isEmpty)
    let end = try #require(result.end)
    guard case .unique(let first) = result.start.dateResolution,
      case .unique(let last) = end.dateResolution
    else { throw ChronoError.invalidDate }
    #expect(first.instant == result.ref.instant)
    #expect(last.instant.addingTimeInterval(1) == result.ref.instant.addingTimeInterval(7_200))
    #expect(result.start.isCertain(component: .second))
  }

  @Test(arguments: [("两小时后", Language.chineseSimplified), ("兩小時後", .chinese)])
  func afterNamesOnlyTheDestination(text: String, language: Language) throws {
    let result = try parse(text, language: language)
    #expect(result.issues.isEmpty)
    #expect(result.end == nil)
    guard case .unique(let date) = result.start.dateResolution else {
      throw ChronoError.invalidDate
    }
    #expect(date.instant == result.ref.instant.addingTimeInterval(7_200))
    #expect(result.start.isCertain(component: .hour))
    #expect(!result.start.isCertain(component: .minute))
  }

  @Test(arguments: [
    ("零小时内", Language.chineseSimplified), ("几小时内", .chineseSimplified),
    ("半月内", .chineseSimplified), ("零小時內", .chinese),
    ("幾小時內", .chinese), ("半月內", .chinese),
  ])
  func invalidWindowsDoNotBecomeOffsets(text: String, language: Language) throws {
    let result = try parse(text, language: language)
    #expect(!result.issues.isEmpty)
  }

  private func parse(_ text: String, language: Language) throws -> ParsedResult {
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
}
