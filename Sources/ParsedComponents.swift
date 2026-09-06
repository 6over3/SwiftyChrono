// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

public struct ParsedComponents {
  public private(set) var knownValues: [ComponentUnit: Int] = [:]
  public private(set) var impliedValues: [ComponentUnit: Int] = [:]
  public let calendar: Calendar
  /// An explicitly written zone, distinct from the captured reference calendar.
  public private(set) var timeZone: TimeZone?
  private var computedDate: ChronoDate?
  var dayPeriod: DayPeriod?

  init(components: [ComponentUnit: Int]?, ref: ChronoDate, implyReferenceDate: Bool = true) {
    calendar = ref.calendar
    if let components { knownValues = components }
    if implyReferenceDate {
      imply(.day, to: ref.day)
      imply(.month, to: ref.month)
      imply(.year, to: ref.year)
    }
    // A date-only expression has a civil noon anchor; certainty remains separate.
    imply(.hour, to: 12)
    imply(.minute, to: 0)
    imply(.second, to: 0)
    imply(.millisecond, to: 0)
  }

  public func clone() -> ParsedComponents { self }

  public subscript(component: ComponentUnit) -> Int? {
    knownValues[component] ?? impliedValues[component]
  }

  public mutating func assign(_ component: ComponentUnit, value: Int?) {
    guard let value else { return }
    computedDate = nil
    knownValues[component] = value
    impliedValues.removeValue(forKey: component)
  }

  public mutating func imply(_ component: ComponentUnit, to value: Int?) {
    guard let value, knownValues[component] == nil else { return }
    computedDate = nil
    impliedValues[component] = value
  }

  public func isCertain(component: ComponentUnit) -> Bool {
    knownValues[component] != nil
  }

  /// Changes the written zone without retaining an instant computed in another zone.
  public mutating func assign(timeZone: TimeZone) {
    if computedDate?.calendar.timeZone != timeZone { computedDate = nil }
    self.timeZone = timeZone
  }

  /// Calendar arithmetic already identifies an instant, including which occurrence
  /// of a repeated hour it belongs to. Field certainty still describes its bucket.
  mutating func assign(date: ChronoDate, precision: RelativeDateUnit) throws {
    guard precision != .week, precision != .month, precision != .year
    else { throw ChronoError.invalidDate }
    assign(.year, value: date.year)
    assign(.month, value: date.month)
    assign(.day, value: date.day)
    switch precision {
    case .second:
      assign(.second, value: date.second)
      fallthrough
    case .minute:
      assign(.minute, value: date.minute)
      fallthrough
    case .hour:
      assign(.hour, value: date.hour)
    case .day: break
    case .week, .month, .year: throw ChronoError.invalidDate
    }
    imply(.hour, to: date.hour)
    imply(.minute, to: date.minute)
    imply(.second, to: date.second)
    imply(.millisecond, to: date.nanosecond / 1_000_000)
    computedDate = date
  }

  /// Calendar-day arithmetic must carry month/year rollover without turning
  /// implied date fields into explicitly supplied fields.
  mutating func shiftCalendarDays(_ days: Int) throws {
    guard let civil = ParsedCivilTime(self)?.civilDate(),
      let shifted = civil.calendar.date(byAdding: .day, value: days, to: civil.date)
    else { throw ChronoError.invalidDate }
    for (unit, component) in [
      (ComponentUnit.year, Calendar.Component.year), (.month, .month), (.day, .day),
    ] {
      let value = civil.calendar.component(component, from: shifted)
      if isCertain(component: unit) { assign(unit, value: value) } else { imply(unit, to: value) }
    }
  }

  /// Named zones retain their historical rules; offsets remain fixed-offset zones.
  public var resolvedCalendar: Calendar {
    var resolved = calendar
    if let timeZone { resolved.timeZone = timeZone }
    return resolved
  }

  /// Resolves without silently selecting a repeated time or normalizing a missing one.
  public var dateResolution: ParsedDateResolution {
    guard let civil = ParsedCivilTime(self) else { return .invalid(.invalidComponents) }
    let resolved = resolvedCalendar
    if let computedDate, computedDate.calendar == resolved {
      return .unique(computedDate)
    }
    return civil.resolve(in: resolved)
  }

  /// An invalid endpoint cannot justify reordering or advancing a range.
  func isDefinitelyBefore(_ other: ParsedComponents) -> Bool {
    guard let left = dateResolution.bounds, let right = other.dateResolution.bounds else {
      return false
    }
    return left.latest < right.earliest
  }

  func isDefinitelyBefore(_ instant: Date) -> Bool {
    guard let bounds = dateResolution.bounds else { return false }
    return bounds.latest < instant
  }

  /// A time-range endpoint inherits date fields, not one arbitrarily resolved instant.
  init(inheritingDateFrom start: ParsedComponents, ref: ChronoDate) {
    self.init(components: nil, ref: ref, implyReferenceDate: false)
    for component in [ComponentUnit.year, .month, .day] {
      imply(component, to: start[component])
    }
  }
}
