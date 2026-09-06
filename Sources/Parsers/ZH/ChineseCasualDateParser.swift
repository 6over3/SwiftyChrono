// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

final class ChineseCasualDateParser: Parser {
  enum Script { case simplified, traditional }
  let script: Script
  override var language: Language { script == .simplified ? .chineseSimplified : .chinese }
  override var pattern: String {
    let days: String
    let periods: String
    switch script {
    case .simplified:
      days = "大前|大后|今|明|前|后|昨"
      periods = "上午|早上|下午|晚上|夜晚|夜|中午|凌晨"
    case .traditional:
      days = "大前|大後|今|明|前|後|聽|昨|尋|琴"
      periods = "上午|上晝|朝早|早上|下午|下晝|晏晝|晚上|夜晚|夜|中午|凌晨"
    }
    return
      "(?:(?<day>\(days))(?:(?:日|天)[\\s,，]*(?<period>\(periods))?|(?<shortPeriod>早|朝|晚))|(?<floatingPeriod>\(periods)))"
  }

  init(script: Script, strictMode: Bool) {
    self.script = script
    super.init(strictMode: strictMode)
  }

  override func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let value = try match.string(from: text, atRangeIndex: 0)
    var result = ParsedResult(ref: ref, index: match.range.location, text: value)
    if let range = Range(match.range(withName: "day"), in: text) {
      let offset: Int
      switch text[range] {
      case "今": offset = 0
      case "明", "聽": offset = 1
      case "昨", "尋", "琴": offset = -1
      case "前": offset = -2
      case "大前": offset = -3
      case "后", "後": offset = 2
      case "大后", "大後": offset = 3
      default: throw ChronoError.invalidSourceRange
      }
      try result.start.assign(date: ref.added(offset, .day), precision: .day)
    }
    for name in ["period", "shortPeriod", "floatingPeriod"] {
      guard let range = Range(match.range(withName: name), in: text) else { continue }
      guard let period = DayPeriod(chineseText: String(text[range]), language: language)
      else { throw ChronoError.invalidSourceRange }
      result.start.dayPeriod = period
    }
    return result
  }
}
