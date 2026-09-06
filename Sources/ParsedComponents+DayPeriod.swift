import Foundation

extension ParsedComponents {
  /// Applies a period only after the date, clock, and written zone have composed.
  /// The return value is a full period; a qualified written clock stays one endpoint.
  mutating func resolveDayPeriod() throws(ParsedDateIssue) -> DateInterval? {
    guard let period = dayPeriod else { return nil }
    if period.phase == .midnight { throw .unresolvedDayPeriod }
    if period.phase == .noon {
      if isCertain(component: .meridiem), self[.meridiem] != 1 { throw .invalidComponents }
      for (component, value) in [(ComponentUnit.hour, 12), (.minute, 0), (.second, 0)] {
        if isCertain(component: component), self[component] != value { throw .invalidComponents }
      }
      assign(.hour, value: 12)
      assign(.minute, value: 0)
      assign(.second, value: 0)
      dayPeriod = nil
      return nil
    }
    guard let hours = period.hours(in: resolvedCalendar.locale) else {
      throw .unresolvedDayPeriod
    }
    if isCertain(component: .hour) {
      guard let hour = self[.hour], (0..<24).contains(hour) else {
        throw .invalidComponents
      }
      let possibilities =
        isCertain(component: .meridiem) || hour == 0 || hour >= 12 ? [hour] : [hour, hour + 12]
      let admitted = possibilities.filter { hours.contains($0) || hours.contains($0 + 24) }
      guard admitted.count == 1, let resolved = admitted.first else {
        throw .invalidComponents
      }
      assign(.hour, value: resolved)
      dayPeriod = nil
      return nil
    }
    guard isCertain(component: .day) || isCertain(component: .weekday), hours.upperBound <= 24
    else {
      throw .unresolvedDayPeriod
    }
    let calendar = resolvedCalendar
    guard ParsedCivilTime(self)?.civilDate() != nil else { throw .invalidComponents }
    guard let year = self[.year], let month = self[.month], let day = self[.day] else {
      throw .invalidComponents
    }
    let civil = DateComponents(year: year, month: month, day: day)
    guard let anchor = calendar.date(from: civil), calendar.date(anchor, matchesComponents: civil),
      let dayInterval = calendar.dateInterval(of: .day, for: anchor)
    else { throw .nonexistentLocalTime }
    let start = try dayPeriodBoundary(hours.lowerBound, within: dayInterval, calendar: calendar)
    let end = try dayPeriodBoundary(hours.upperBound, within: dayInterval, calendar: calendar)
    guard start < end else { throw .nonexistentLocalTime }
    dayPeriod = nil
    return DateInterval(start: start, end: end)
  }

  private func dayPeriodBoundary(_ hour: Int, within day: DateInterval, calendar: Calendar)
    throws(ParsedDateIssue) -> Date
  {
    if hour == 0 { return day.start }
    if hour == 24 { return day.end }
    guard
      let date = calendar.date(
        bySettingHour: hour, minute: 0, second: 0, of: day.start,
        matchingPolicy: .nextTime, repeatedTimePolicy: .first),
      date >= day.start, date <= day.end
    else { throw .nonexistentLocalTime }
    return date
  }
}

extension ParsedResult {
  /// Resolve meridiem qualifiers before comparing range endpoints for rollover.
  /// A failed endpoint retains the complete expression and its original fields.
  mutating func resolveClockQualifiers() {
    guard issues.isEmpty else { return }
    var resolved = self
    do {
      if resolved.start.isCertain(component: .hour) { _ = try resolved.start.resolveDayPeriod() }
      if var end = resolved.end, end.isCertain(component: .hour) {
        _ = try end.resolveDayPeriod()
        resolved.end = end
      }
      self = resolved
    } catch {
      issues.append(error)
    }
  }
}
