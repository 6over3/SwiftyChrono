import Foundation

enum RelativeDateDirection {
  case past, future

  func signed(_ amount: Int) throws -> Int {
    guard amount >= 0 else { throw ChronoError.invalidDate }
    return self == .past ? -amount : amount
  }
}

extension ChronoDate {
  func offset(
    amount: RelativeDateAmount, unit: RelativeDateUnit, direction: RelativeDateDirection
  ) throws -> (date: ChronoDate, precision: RelativeDateUnit) {
    guard (1...9999).contains(year) else { throw ChronoError.invalidDate }
    let date: ChronoDate
    let precision: RelativeDateUnit
    switch amount {
    case .whole(let number):
      let signed = try direction.signed(number)
      // Stay inside the civil domain before asking Foundation to add a huge Int.
      guard let first = calendar.date(from: DateComponents(year: 1, month: 1, day: 1)),
        let last = calendar.date(
          from: DateComponents(
            year: 9999, month: 12, day: 31,
            hour: 23, minute: 59, second: 59)),
        let lower = calendar.dateComponents([unit.calendarComponent], from: instant, to: first)
          .value(for: unit.calendarComponent),
        let upper = calendar.dateComponents([unit.calendarComponent], from: instant, to: last)
          .value(for: unit.calendarComponent),
        (lower...upper).contains(signed)
      else { throw ChronoError.invalidDate }
      date = try added(signed, unit.calendarComponent)
      switch unit {
      case .week, .month, .year: precision = .day
      default: precision = unit
      }
    case .half:
      switch unit {
      case .second:
        throw ChronoError.invalidDate
      case .minute:
        date = try added(direction.signed(30), .second)
        precision = .second
      case .hour:
        date = try added(direction.signed(30), .minute)
        precision = .minute
      case .day:
        date = try added(direction.signed(12), .hour)
        precision = .hour
      case .week:
        date = try added(direction.signed(3), .day).added(direction.signed(12), .hour)
        precision = .hour
      case .month:
        // A month is not a fixed duration; there is no unambiguous half-month date.
        throw ChronoError.invalidDate
      case .year:
        date = try added(direction.signed(6), .month)
        precision = .day
      }
    }
    guard (1...9999).contains(date.year) else { throw ChronoError.invalidDate }
    return (date, precision)
  }
}

extension ParsedResult {
  /// Quantified periods and deadlines include the intervening time, not just
  /// the destination bucket. The captured reference is rounded to one second.
  mutating func applyRollingRange(
    amount: RelativeDateAmount, unit: RelativeDateUnit, direction: RelativeDateDirection
  ) throws {
    if case .half = amount, unit == .second {
      issues.append(.unsupportedPrecision)
      return
    }
    let reference = ChronoDate(
      instant: Date(timeIntervalSince1970: floor(ref.timeIntervalSince1970)), calendar: ref.calendar
    )
    let shifted = try reference.offset(amount: amount, unit: unit, direction: direction).date
    let start = direction == .past ? shifted.instant : reference.instant
    let end = direction == .past ? reference.instant : shifted.instant
    try assignRange(DateInterval(start: start, end: end), precision: .second)
  }

  /// Parsed ranges have inclusive endpoint buckets. Use the last second inside
  /// a half-open calendar interval so callers do not include the following period.
  mutating func assignRange(_ interval: DateInterval, precision: RelativeDateUnit) throws {
    guard interval.start < interval.end else { throw ChronoError.invalidDate }
    let first = ChronoDate(instant: interval.start, calendar: ref.calendar)
    let last = ChronoDate(instant: interval.end.addingTimeInterval(-1), calendar: ref.calendar)
    guard (1...9999).contains(first.year), (1...9999).contains(last.year)
    else { throw ChronoError.invalidDate }
    try start.assign(date: first, precision: precision)
    var endpoint = ParsedComponents(components: nil, ref: ref)
    try endpoint.assign(date: last, precision: precision)
    end = endpoint
  }

  /// Offset expressions name a date or clock bucket, not an arbitrary week.
  mutating func applyOffset(
    amount: RelativeDateAmount, unit: RelativeDateUnit, direction: RelativeDateDirection
  ) throws {
    if case .half = amount, unit == .second {
      issues.append(.unsupportedPrecision)
      return
    }
    let resolved = try ref.offset(amount: amount, unit: unit, direction: direction)
    try start.assign(date: resolved.date, precision: resolved.precision)
  }
}
