import Foundation

extension TemporalComparisonGrammar {
  struct Rule {
    let comparison: TemporalComparison
    let pattern: String
    let suffix: Bool

    init(_ comparison: TemporalComparison, prefix: String, article: String? = nil) {
      self.comparison = comparison
      let phrase = prefix.replacingOccurrences(of: " ", with: "\\s+")
      let qualifier: String
      if let article {
        qualifier = "(?:\\s+(?:\(article)))?"
      } else {
        qualifier = ""
      }
      // Elided articles end in an apostrophe immediately before their operand.
      pattern = "(?<![\\p{L}\\p{N}_])(?:\(phrase))\(qualifier)(?:(?![\\p{L}\\p{N}_])|(?<=['’]))"
      suffix = false
    }

    init(_ comparison: TemporalComparison, suffix: String) {
      self.comparison = comparison
      pattern = suffix
      self.suffix = true
    }
  }

  static func rules(for language: Language) -> [Rule] {
    switch language {
    case .neutral: []
    case .english:
      [
        .init(.before, prefix: "before|earlier than", article: "the"),
        .init(.after, prefix: "after|later than", article: "the"),
        .init(.since, prefix: "since", article: "the"),
        .init(.through, prefix: "through|up to and including", article: "the"),
        .init(.unresolved, prefix: "until", article: "the"),
      ]
    case .french:
      [
        .init(.before, prefix: "avant", article: "le|la|les|l['’]"),
        .init(.after, prefix: "après", article: "le|la|les|l['’]"),
        .init(.since, prefix: "depuis", article: "le|la|les|l['’]"),
        .init(.unresolved, prefix: "jusqu['’](?:à|au|aux)", article: "la|l['’]"),
      ]
    case .german:
      [
        .init(.before, prefix: "vor", article: "dem|der|den"),
        .init(.after, prefix: "nach", article: "dem|der|den"),
        .init(.since, prefix: "seit|ab", article: "dem|der|den"),
        .init(.unresolved, prefix: "bis", article: "zum|zur"),
      ]
    case .spanish:
      [
        .init(.before, prefix: "antes del?", article: "la|las|los"),
        .init(.after, prefix: "después del?", article: "la|las|los"),
        .init(.since, prefix: "desde", article: "el|la|las|los"),
        .init(.unresolved, prefix: "hasta", article: "el|la|las|los"),
      ]
    case .catalan:
      [
        .init(.before, prefix: "abans del?", article: "la|les|els|l['’]"),
        .init(.after, prefix: "després del?", article: "la|les|els|l['’]"),
        .init(.since, prefix: "des del?", article: "la|les|els|l['’]"),
        .init(.unresolved, prefix: "fins al?", article: "la|les|els|l['’]"),
      ]
    case .russian:
      [
        .init(.before, prefix: "до"), .init(.after, prefix: "после"),
        .init(.since, prefix: "начиная с"),
      ]
    case .japanese:
      [
        .init(.before, suffix: "より前"), .init(.after, suffix: "より後"),
        .init(.since, suffix: "以降|以後"), .init(.through, suffix: "以前"),
        .init(.unresolved, suffix: "まで"),
      ]
    case .chineseSimplified:
      [
        .init(.before, suffix: "之前|以前"), .init(.after, suffix: "之后|以后"),
        .init(.since, suffix: "以来"),
      ]
    case .chinese:
      [
        .init(.before, suffix: "之前|以前"), .init(.after, suffix: "之後|以後"),
        .init(.since, suffix: "以來"),
      ]
    }
  }
}
