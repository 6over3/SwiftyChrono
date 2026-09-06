import Foundation

extension RelativePeriodRule {
  static var german: [Self] {
    [
      .words(
        .german,
        "(?:(?<previous>letzt(?:e|en|er|es)|vergangen(?:e|en|er|es))|(?<next>n[aä]chst(?:e|en|er|es))|(?<current>dies(?:e|en|er|es)))\\s+"
          + "(?<amount>\(DE_INTEGER_WORDS_PATTERN)|[0-9]+|halbe(?:n|s)?)?\\s*"
          + "(?<unit>sekunden?|minuten?|stunden?|tag(?:en|e)?|wochen?|monat(?:en|e|s)?|jahr(?:en|es|e)?)"
      )
    ]
  }
}
