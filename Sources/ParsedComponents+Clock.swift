extension ParsedComponents {
  /// Merging a clock preserves its precision and any explicit endpoint offset.
  mutating func applyClock(from clock: ParsedComponents) {
    for component in [ComponentUnit.hour, .minute, .second, .millisecond, .timeZoneOffset] {
      guard let value = clock[component] else { continue }
      if clock.isCertain(component: component) { assign(component, value: value) }
      else { imply(component, to: value) }
    }
  }
}
