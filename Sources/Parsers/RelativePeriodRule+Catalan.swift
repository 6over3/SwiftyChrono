import Foundation

extension RelativePeriodRule {
  static var catalan: [Self] {
    let unit = "(?<unit>segons?|minuts?|hor(?:a|es)|di(?:a|es)|setman(?:a|es)|mes(?:os)?|anys?)"
    let amount = "(?<amount>\(CA_INTEGER_WORDS_PATTERN)|[0-9]+|mig|mitja)?"
    return [
      .words(.catalan, unit + "\\s+(?:(?<previous>passad[ae]s?|passats?)|(?<next>vinents?))"),
      .words(
        .catalan,
        "(?:(?<previous>[uú]ltim[ae]s?|[uú]ltims?)|(?<next>pr[oò]xim[ae]s?|pr[oò]xims?)|(?<current>aquest(?:a|es|s)?))\\s+"
          + amount + "\\s*" + unit),
    ]
  }
}
