import Foundation

extension RelativePeriodRule {
  static var french: [Self] {
    let unit = "(?<unit>secondes?|min(?:ute)?s?|heures?|jours?|semaines?|mois|années?|ans?)"
    let amount = "(?<amount>\(FR_INTEGER_WORDS_PATTERN)|[0-9]+|une?|demi(?:\\s*|-?)?)?"
    return [
      .words(
        .french, unit + "\\s+(?:(?<previous>derni[eè]res?|derniers?)|(?<next>prochain(?:e|es|s)?))"),
      .words(
        .french,
        amount
          + "\\s*(?:(?<previous>derni[eè]res?|derniers?)|(?<next>prochain(?:e|es|s)?))\\s+" + unit),
      .words(.french, "(?<current>ce|cet|cette)\\s+" + unit),
    ]
  }
}
