import Foundation

extension RelativePeriodRule {
  static var english: [Self] {
    [
      .words(
        .english,
        "(?:(?<previous>last)|(?<next>next)|(?<current>this)|(?<past>past))\\s*"
          + "(?<amount>\(EN_INTEGER_WORDS_PATTERN)|[0-9]+|few|half(?:\\s*an?)?)?\\s*"
          + "(?<unit>seconds?|min(?:ute)?s?|hours?|days?|weeks?|months?|years?)")
    ]
  }
}
