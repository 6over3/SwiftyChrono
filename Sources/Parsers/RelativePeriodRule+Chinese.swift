import Foundation

extension RelativePeriodRule {
  static var simplifiedChinese: [Self] {
    [
      .unspaced(
        .chineseSimplified, "(?:(?<previous>上)|(?<next>下)|(?<current>本|这))个?(?<unit>周|星期|礼拜|月)"),
      .unspaced(.chineseSimplified, "(?:(?<previous>去)|(?<next>明)|(?<current>今))(?<unit>年)"),
      .unspaced(
        .chineseSimplified,
        "(?:(?<past>过去)|(?<next>未来))\\s*(?<amount>[0-9]+|[一二两三四五六七八九十]+|半)\\s*个?"
          + "(?<unit>秒钟?|分钟?|小时|天|日|周|星期|礼拜|月|年)"),
    ]
  }

  static var traditionalChinese: [Self] {
    [
      .unspaced(.chinese, "(?:(?<previous>上)|(?<next>下)|(?<current>本|這))個?(?<unit>週|星期|禮拜|月)"),
      .unspaced(.chinese, "(?:(?<previous>去)|(?<next>明)|(?<current>今))(?<unit>年)"),
      .unspaced(
        .chinese,
        "(?:(?<past>過去)|(?<next>未來))\\s*(?<amount>[0-9]+|[一二兩三四五六七八九十]+|半)\\s*個?"
          + "(?<unit>秒鐘?|分鐘?|小時|天|日|週|星期|禮拜|月|年)"),
    ]
  }
}
