import Foundation

/// Gregorian fields before a time zone maps them to one or more instants.
struct ParsedCivilTime {
  let components: DateComponents
  let millisecond: Int

  init?(_ parsed: ParsedComponents) {
    guard let year = parsed[.year], (1...9999).contains(year),
      let month = parsed[.month], (1...12).contains(month),
      let day = parsed[.day], (1...31).contains(day),
      let hour = parsed[.hour], (0...23).contains(hour),
      let minute = parsed[.minute], (0...59).contains(minute),
      let second = parsed[.second], (0...59).contains(second),
      let millisecond = parsed[.millisecond], (0...999).contains(millisecond)
    else { return nil }
    components = DateComponents(
      year: year, month: month, day: day, hour: hour, minute: minute, second: second)
    self.millisecond = millisecond
  }

  /// A coordinate for civil-field arithmetic only, never a resolved query instant.
  func civilDate() -> (date: Date, calendar: Calendar)? {
    guard let zeroOffset = TimeZone(secondsFromGMT: 0) else { return nil }
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = zeroOffset
    guard components.isValidDate(in: calendar), let date = calendar.date(from: components),
      calendar.date(date, matchesComponents: components)
    else { return nil }
    return (date, calendar)
  }

  func resolve(in calendar: Calendar) -> ParsedDateResolution {
    guard civilDate() != nil else { return .invalid(.invalidComponents) }
    // date(from:) locates the civil day; its default choice is not accepted as
    // a resolution. Both repeated-time policies must match the original fields.
    guard let anchor = calendar.date(from: components),
      let hour = components.hour, let minute = components.minute, let second = components.second,
      let first = calendar.date(
        bySettingHour: hour, minute: minute, second: second, of: anchor,
        matchingPolicy: .strict, repeatedTimePolicy: .first),
      let last = calendar.date(
        bySettingHour: hour, minute: minute, second: second, of: anchor,
        matchingPolicy: .strict, repeatedTimePolicy: .last),
      calendar.date(first, matchesComponents: components),
      calendar.date(last, matchesComponents: components)
    else { return .invalid(.nonexistentLocalTime) }
    let fraction = TimeInterval(millisecond) / 1000
    let earlier = ChronoDate(instant: min(first, last).addingTimeInterval(fraction), calendar: calendar)
    guard first != last else { return .unique(earlier) }
    let later = ChronoDate(instant: max(first, last).addingTimeInterval(fraction), calendar: calendar)
    return .repeated(earlier: earlier, later: later)
  }
}
