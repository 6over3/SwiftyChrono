import Foundation

extension RelativePeriodRule {
  static var japanese: [Self] {
    [
      .unspaced(.japanese, "(?<previous>先)(?<unit>週|月)"),
      .unspaced(.japanese, "(?<previous>去|昨)(?<unit>年)"),
      .unspaced(.japanese, "(?:(?<current>今)|(?<next>来))(?<unit>週|月|年)"),
      .unspaced(
        .japanese,
        "(?:(?<past>過去)|(?<next>今後))\\s*(?<amount>[0-9]+|[一二三四五六七八九十]+|半)\\s*"
          + "(?<unit>秒間?|分間?|時間|日間?|週間?|[かヶケ箇]月(?:間)?|年間?)"),
    ]
  }
}
