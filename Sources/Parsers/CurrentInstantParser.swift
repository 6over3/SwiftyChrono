import Foundation

/// Native grammar words share the same captured instant; none imply a whole day.
final class CurrentInstantParser: Parser {
  private let grammarLanguage: Language
  private let expression: String
  override var language: Language { grammarLanguage }
  override var pattern: String { expression }

  private init(language: Language, pattern: String) {
    grammarLanguage = language
    expression = pattern
    super.init(strictMode: false)
  }

  static var all: [CurrentInstantParser] {
    let words: [(Language, String)] = [
      (.english, "now"), (.spanish, "ahora"), (.catalan, "ara"),
      (.french, "maintenant"), (.german, "jetzt"), (.russian, "сейчас"),
    ]
    return words.map { language, word in
      Self(
        language: language,
        pattern: "(?<![\\p{L}\\p{N}_])(?<instant>\(word))(?=$|[^\\p{L}\\p{N}_])")
    } + [
      Self(language: .chineseSimplified, pattern: "(?<instant>现在|立(?:刻|即)|即刻)"),
      Self(language: .chinese, pattern: "(?<instant>而家|立(?:刻|即)|即刻)"),
    ]
  }

  override func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    let range = match.range(withName: "instant")
    guard let source = Range(range, in: text) else { throw ChronoError.invalidSourceRange }
    var result = ParsedResult(ref: ref, index: range.location, text: String(text[source]))
    try result.start.assign(date: ref, precision: .second)
    return result
  }
}
