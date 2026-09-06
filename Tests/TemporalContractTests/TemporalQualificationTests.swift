import Foundation
import Testing

@testable import SwiftyChrono

@Suite("Comparison qualifiers and unfinished input")
struct TemporalQualificationTests {
  @Test(arguments: [
    ("before the Monday", Language.english), ("avant le lundi", .french),
    ("vor dem Montag", .german), ("antes del lunes", .spanish),
    ("abans del dilluns", .catalan),
    ("avant la semaine dernière", .french), ("before the last week", .english),
  ])
  func articlesBelongToTheOperator(text: String, language: Language) throws {
    let result = try one(text, language: language)
    #expect(result.issues.isEmpty)
    #expect(result.comparison == .before)
  }

  @Test(arguments: [
    ("Monday before", Language.english), ("Monday before the", .english),
    ("lundi après", .french), ("Montag nach", .german),
    ("lunes después de", .spanish), ("dilluns abans de", .catalan),
    ("понедельник после", .russian), ("after Monday before", .english),
  ])
  func unfinishedComparisonCannotApplyItsDate(text: String, language: Language) throws {
    let result = try one(text, language: language)
    #expect(!result.issues.isEmpty)
  }

  @Test("An unrelated clause does not become an unfinished date comparison")
  func separateProse() throws {
    let result = try #require(parse("Monday notes before dinner", language: .english).first)
    #expect(result.text == "Monday")
    #expect(result.comparison == nil)
    #expect(result.issues.isEmpty)
  }

  @Test(arguments: [
    ("avant l’été dernier", "été dernier", Language.french),
    ("avant l'été dernier", "été dernier", .french),
    ("antes del verano pasado", "verano pasado", .spanish),
    ("abans de l’estiu", "estiu", .catalan),
    ("before\t the\n summer", "summer", .english),
  ])
  func externalOperandsKeepArticlesAndApostrophes(
    text: String, operand: String, language: Language
  ) throws {
    let range = try #require(text.range(of: operand))
    let binding = try #require(
      try TemporalComparisonGrammar.binding(
        to: NSRange(range, in: text), in: text, language: language))
    #expect(binding.comparison == .before)
    #expect(binding.range == NSRange(text.startIndex..., in: text))
  }

  @Test("A comparison word inside another word is not an operator")
  func wordBoundaries() throws {
    let text = "thereafter Monday"
    let range = try #require(text.range(of: "Monday"))
    #expect(
      try TemporalComparisonGrammar.binding(
        to: NSRange(range, in: text), in: text, language: .english) == nil)
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
    let reference = try #require(
      calendar.date(
        from:
          DateComponents(year: 2026, month: 1, day: 4, hour: 15)))
    return try Chrono().parse(
      text: text, refDate: reference, calendar: calendar, languages: [language])
  }
}
