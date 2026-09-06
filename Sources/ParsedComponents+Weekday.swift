import Foundation

enum WeekdayReference {
  case nearest, previousOccurrence, nextOccurrence, previousWeek, nextWeek, currentWeek

  func date(for offset: Int, relativeTo ref: ChronoDate) throws -> ChronoDate {
    guard (0...6).contains(offset) else { throw ChronoError.invalidDate }
    let calendar = ref.calendar
    let day = calendar.startOfDay(for: ref.instant)
    let date: Date
    switch self {
    case .nearest:
      if ref.weekday == offset {
        date = day
      } else {
        let past = try occurrence(of: offset, relativeTo: ref, direction: .backward)
        let future = try occurrence(of: offset, relativeTo: ref, direction: .forward)
        guard let before = calendar.dateComponents([.day], from: past, to: day).day,
          let after = calendar.dateComponents([.day], from: day, to: future).day,
          before != after
        else { throw ChronoError.invalidDate }
        date = before < after ? past : future
      }
    case .previousOccurrence:
      date = try occurrence(of: offset, relativeTo: ref, direction: .backward)
    case .nextOccurrence:
      date = try occurrence(of: offset, relativeTo: ref, direction: .forward)
    case .previousWeek: date = try dateInWeek(-1, weekday: offset, relativeTo: ref)
    case .nextWeek: date = try dateInWeek(1, weekday: offset, relativeTo: ref)
    case .currentWeek: date = try dateInWeek(0, weekday: offset, relativeTo: ref)
    }
    guard calendar.component(.weekday, from: date) == offset + 1,
      (1...9999).contains(calendar.component(.year, from: date))
    else { throw ChronoError.invalidDate }
    return ChronoDate(instant: date, calendar: calendar)
  }

  private func occurrence(
    of weekday: Int, relativeTo ref: ChronoDate, direction: Calendar.SearchDirection
  ) throws -> Date {
    let calendar = ref.calendar
    guard let day = calendar.dateInterval(of: .day, for: ref.instant) else {
      throw ChronoError.invalidDate
    }
    // Directional wording excludes the entire reference day, not just its clock.
    let boundary = direction == .backward ? day.start : day.end.addingTimeInterval(-1)
    guard
      let date = calendar.nextDate(
        after: boundary, matching: DateComponents(weekday: weekday + 1),
        matchingPolicy: .strict, direction: direction)
    else { throw ChronoError.invalidDate }
    return date
  }

  private func dateInWeek(_ weeks: Int, weekday: Int, relativeTo ref: ChronoDate) throws -> Date {
    let calendar = ref.calendar
    guard let current = calendar.dateInterval(of: .weekOfYear, for: ref.instant),
      let shifted = calendar.date(byAdding: .weekOfYear, value: weeks, to: current.start),
      let week = calendar.dateInterval(of: .weekOfYear, for: shifted),
      let date = calendar.nextDate(
        after: week.start.addingTimeInterval(-1), matching: DateComponents(weekday: weekday + 1),
        matchingPolicy: .strict),
      date >= week.start, date < week.end
    else { throw ChronoError.invalidDate }
    return date
  }
}

extension ParsedComponents {
  /// The unqualified weekday uses the same nearest occurrence in every grammar.
  mutating func assignWeekday(
    _ offset: Int, relativeTo ref: ChronoDate, reference: WeekdayReference
  ) throws {
    let date = try reference.date(for: offset, relativeTo: ref)
    assign(.weekday, value: offset)
    for (unit, value) in [(ComponentUnit.year, date.year), (.month, date.month), (.day, date.day)] {
      switch reference {
      case .previousOccurrence, .nextOccurrence, .previousWeek, .nextWeek, .currentWeek:
        assign(unit, value: value)
      case .nearest: imply(unit, to: value)
      }
    }
    switch reference {
    case .previousWeek, .nextWeek, .currentWeek:
      guard let week = ref.calendar.dateInterval(of: .weekOfYear, for: date.instant) else {
        throw ChronoError.invalidDate
      }
      calendarContext = ParsedCalendarContext(calendar: ref.calendar, interval: week)
    case .nearest, .previousOccurrence, .nextOccurrence: break
    }
  }
}

extension ParsedResult {
  /// Every written modifier must identify the same day. No modifier is discarded.
  mutating func applyWeekday(
    _ offset: Int, relativeTo ref: ChronoDate, references: [WeekdayReference]
  ) throws {
    guard let first = references.first else {
      try start.assignWeekday(offset, relativeTo: ref, reference: .nearest)
      return
    }
    var resolved = start
    try resolved.assignWeekday(offset, relativeTo: ref, reference: first)
    for reference in references.dropFirst() {
      var candidate = start
      try candidate.assignWeekday(offset, relativeTo: ref, reference: reference)
      guard [ComponentUnit.year, .month, .day].allSatisfy({ resolved[$0] == candidate[$0] }) else {
        issues.append(.invalidComponents)
        return
      }
      if candidate.calendarContext != nil { resolved = candidate }
    }
    start = resolved
  }
}
