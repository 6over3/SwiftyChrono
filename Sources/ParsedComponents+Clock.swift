extension ParsedComponents {
  /// Merging a clock preserves its precision and any explicit endpoint offset.
  mutating func applyClock(from clock: ParsedComponents) -> ParsedDateIssue? {
    if let written = timeZone, let incoming = clock.timeZone, written != incoming {
      return .invalidTimeZone
    }
    if let incoming = clock.dayPeriod {
      if let dayPeriod, dayPeriod != incoming { return .invalidComponents }
      dayPeriod = incoming
    }
    for component in [ComponentUnit.hour, .minute, .second, .millisecond, .meridiem] {
      guard let value = clock[component] else { continue }
      if clock.isCertain(component: component) {
        assign(component, value: value)
      } else {
        imply(component, to: value)
      }
    }
    if let timeZone = clock.timeZone { assign(timeZone: timeZone) }
    return nil
  }
}
