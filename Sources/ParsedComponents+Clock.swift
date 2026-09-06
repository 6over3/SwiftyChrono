extension ParsedComponents {
  /// Merging a clock preserves its precision and any explicit endpoint offset.
  mutating func applyClock(from clock: ParsedComponents) -> ParsedDateIssue? {
    if let written = timeZone, let incoming = clock.timeZone, written != incoming {
      return .invalidTimeZone
    }
    for component in [ComponentUnit.hour, .minute, .second, .millisecond] {
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
