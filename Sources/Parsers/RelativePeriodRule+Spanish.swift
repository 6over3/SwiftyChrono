import Foundation

extension RelativePeriodRule {
  static var spanish: [Self] {
    let unit = "(?<unit>segundos?|minutos?|horas?|d[ií]as?|semanas?|mes(?:es)?|años?)"
    let amount = "(?<amount>\(ES_INTEGER_WORDS_PATTERN)|[0-9]+|medi[oa])?"
    return [
      .words(.spanish, unit + "\\s+(?:(?<previous>pasad[oa]s?)|(?<next>pr[oó]xim[oa]s?))"),
      .words(
        .spanish,
        "(?:(?<previous>[uú]ltim[oa]s?)|(?<next>pr[oó]xim[oa]s?)|(?<current>est(?:a|e|os|as)))\\s+"
          + amount + "\\s*" + unit),
    ]
  }
}
