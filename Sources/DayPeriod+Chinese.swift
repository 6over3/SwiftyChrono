extension DayPeriod {
  /// With a written clock, these words are meridiem qualifiers, not the
  /// narrower stand-alone day-period names used for an inferred range.
  init?(chineseClockText: String, language: Language) {
    let phase: Phase
    switch chineseClockText {
    case "早", "早上", "朝", "朝早", "上午", "上晝", "凌晨": phase = .am
    case "下午", "下晝", "晏晝", "晚", "晚上", "夜", "夜晚": phase = .pm
    case "中午": phase = .afternoon1
    default: return nil
    }
    self.init(phase, language: language)
  }

  init?(chineseText: String, language: Language) {
    let phase: Phase
    switch chineseText {
    case "早", "早上": phase = .morning1
    case "朝", "朝早", "上午", "上晝": phase = .morning2
    case "中午": phase = .afternoon1
    case "下午", "下晝", "晏晝": phase = .afternoon2
    case "晚", "晚上", "夜", "夜晚": phase = .evening1
    case "凌晨": phase = .night1
    default: return nil
    }
    self.init(phase, language: language)
  }
}
