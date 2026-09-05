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

  /// Calendar-day arithmetic must carry month/year rollover without turning
  /// implied date fields into explicitly supplied fields.
  mutating func shiftCalendarDays(_ days: Int) throws {
    guard let civil = ParsedCivilTime(self)?.civilDate(),
      let shifted = civil.calendar.date(byAdding: .day, value: days, to: civil.date)
    else { throw ChronoError.invalidDate }
    for (unit, component) in [(ComponentUnit.year, Calendar.Component.year), (.month, .month), (.day, .day)] {
      let value = civil.calendar.component(component, from: shifted)
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

  /// Resolves without silently selecting a repeated time or normalizing a missing one.
  public var dateResolution: ParsedDateResolution {
    guard let civil = ParsedCivilTime(self) else { return .invalid(.invalidComponents) }
    let resolved: Calendar
    do { resolved = try resolvedCalendar }
    catch { return .invalid(.invalidTimeZone) }
    return civil.resolve(in: resolved)
  }

  /// An invalid endpoint cannot justify reordering or advancing a range.
  func isDefinitelyBefore(_ other: ParsedComponents) -> Bool {
    guard let left = dateResolution.bounds, let right = other.dateResolution.bounds else { return false }
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
