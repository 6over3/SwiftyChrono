import Foundation

/// An instant with the immutable civil context used by every parser operation.
public struct ChronoDate {
  public let instant: Date
  public let calendar: Calendar

  init(instant: Date, calendar: Calendar) {
    self.instant = instant
    self.calendar = calendar
  }

  var timeIntervalSince1970: TimeInterval { instant.timeIntervalSince1970 }
  var year: Int { calendar.component(.year, from: instant) }
  var month: Int { calendar.component(.month, from: instant) }
  var day: Int { calendar.component(.day, from: instant) }
  var hour: Int { calendar.component(.hour, from: instant) }
  var minute: Int { calendar.component(.minute, from: instant) }
  var second: Int { calendar.component(.second, from: instant) }
  var nanosecond: Int { calendar.component(.nanosecond, from: instant) }
  var millisecond: Int { nanoSecondsToMilliseconds(nanosecond) }
  // The inherited grammar uses Sunday = 0 through Saturday = 6.
  var weekday: Int { calendar.component(.weekday, from: instant) - 1 }

  func isAfter(_ other: ChronoDate) -> Bool { instant > other.instant }

  func differenceOfTimeInterval(to other: ChronoDate) -> TimeInterval {
    instant.timeIntervalSince(other.instant)
  }

  func numberOf(_ unit: Calendar.Component, inA baseUnit: Calendar.Component) -> Int? {
    calendar.range(of: unit, in: baseUnit, for: instant)?.count
  }

  func added(_ value: Int, _ unit: Calendar.Component) throws -> ChronoDate {
    guard let date = calendar.date(byAdding: unit, value: value, to: instant),
      date.timeIntervalSince1970.isFinite
    else { throw ChronoError.invalidDate }
    return ChronoDate(instant: date, calendar: calendar)
  }

  func setOrAdded(_ value: Int, _ component: Calendar.Component) throws -> ChronoDate {
    let current: Int
    switch component {
    case .year: current = year
    case .month: current = month
    case .day: current = day
    case .hour: current = hour
    case .minute: current = minute
    case .second: current = second
    case .nanosecond: current = nanosecond
    case .weekday: current = weekday
    default: throw ChronoError.invalidCalendar
    }
    let difference = value.subtractingReportingOverflow(current)
    guard !difference.overflow else { throw ChronoError.invalidDate }
    return try added(difference.partialValue, component)
  }
}

func nanoSecondsToMilliseconds(_ nanoseconds: Int) -> Int {
  Int((Double(nanoseconds) / 1_000_000).rounded(.up))
}
