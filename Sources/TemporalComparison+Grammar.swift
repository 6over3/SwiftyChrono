extension TemporalComparisonGrammar {
  struct Rule {
    let comparison: TemporalComparison
    let pattern: String
    let suffix: Bool

    init(_ comparison: TemporalComparison, prefix: String) {
      self.comparison = comparison
      pattern = "(?<![\\p{L}\\p{N}_])(?:\(prefix))(?![\\p{L}\\p{N}_])"
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
        .init(.before, prefix: "before|earlier than"),
        .init(.after, prefix: "after|later than"),
        .init(.since, prefix: "since"), .init(.through, prefix: "through|up to and including"),
        .init(.unresolved, prefix: "until"),
      ]
    case .french:
      [
        .init(.before, prefix: "avant"), .init(.after, prefix: "après"),
        .init(.since, prefix: "depuis"), .init(.unresolved, prefix: "jusqu['’]à"),
      ]
    case .german:
      [
        .init(.before, prefix: "vor"), .init(.after, prefix: "nach"),
        .init(.since, prefix: "seit|ab"), .init(.unresolved, prefix: "bis"),
      ]
    case .spanish:
      [
        .init(.before, prefix: "antes de(?: las)?"),
        .init(.after, prefix: "después de(?: las)?"), .init(.since, prefix: "desde(?: las)?"),
        .init(.unresolved, prefix: "hasta"),
      ]
    case .catalan:
      [
        .init(.before, prefix: "abans de(?: les)?"),
        .init(.after, prefix: "després de(?: les)?"), .init(.since, prefix: "des de(?: les| la)?"),
        .init(.unresolved, prefix: "fins a"),
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
