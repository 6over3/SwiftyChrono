// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

public struct ParsedComponents {
  public var knownValues: [ComponentUnit: Int] = [:]
  public var impliedValues: [ComponentUnit: Int] = [:]
  public let calendar: Calendar

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
    knownValues[component] = value
    impliedValues.removeValue(forKey: component)
  }

  public mutating func imply(_ component: ComponentUnit, to value: Int?) {
    guard let value, knownValues[component] == nil else { return }
    impliedValues[component] = value
  }

  public func isCertain(component: ComponentUnit) -> Bool {
    knownValues[component] != nil
  }

  public func isPossibleDate() -> Bool {
    do { _ = try date; return true }
    catch { return false }
  }

  /// Calendar-day arithmetic must carry month/year rollover without turning
  /// implied date fields into explicitly supplied fields.
  mutating func shiftCalendarDays(_ days: Int) throws {
    let shifted = try date.added(days, .day)
    for (unit, value) in [(ComponentUnit.year, shifted.year), (.month, shifted.month), (.day, shifted.day)] {
      if isCertain(component: unit) { assign(unit, value: value) }
      else { imply(unit, to: value) }
    }
  }

  /// The endpoint's explicit zone takes precedence over the query's captured zone.
  public var resolvedCalendar: Calendar {
    get throws {
      var resolved = calendar
      if let offset = self[.timeZoneOffset] {
        let seconds = offset.multipliedReportingOverflow(by: 60)
        guard !seconds.overflow,
          let zone = TimeZone(secondsFromGMT: seconds.partialValue)
        else { throw ChronoError.invalidDate }
        resolved.timeZone = zone
      }
      return resolved
    }
  }

  /// Rejects invalid components and DST gaps instead of rolling them into another date.
  public var date: ChronoDate {
    get throws {
      let resolved = try resolvedCalendar
      guard let year = self[.year], (1...9999).contains(year),
        let month = self[.month], (1...12).contains(month),
        let day = self[.day], (1...31).contains(day),
        let hour = self[.hour], (0...23).contains(hour),
        let minute = self[.minute], (0...59).contains(minute),
        let second = self[.second], (0...59).contains(second),
        let millisecond = self[.millisecond], (0...999).contains(millisecond)
      else { throw ChronoError.invalidDate }
      let components = DateComponents(
        calendar: resolved, timeZone: resolved.timeZone,
        year: year, month: month, day: day, hour: hour, minute: minute,
        second: second, nanosecond: millisecond * 1_000_000
      )
      guard components.isValidDate(in: resolved), let instant = resolved.date(from: components)
      else { throw ChronoError.invalidDate }
      let check = resolved.dateComponents([.year, .month, .day, .hour, .minute, .second], from: instant)
      guard check.year == year, check.month == month, check.day == day,
        check.hour == hour, check.minute == minute, check.second == second
      else { throw ChronoError.invalidDate }
      return ChronoDate(instant: instant, calendar: resolved)
    }
  }
}
