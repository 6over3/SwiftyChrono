import Foundation

/// A written period can supply context to more than one range endpoint.
struct ParsedCalendarContext {
  let calendar: Calendar
  let interval: DateInterval
}

extension ParsedComponents {
  /// Resolve only if every supplied date field identifies one bucket in the period.
  /// Repeated weekdays need a set of intervals, not an arbitrarily chosen Monday.
  func resolvingDate(in period: ParsedResult) throws(ParsedDateIssue) -> Self {
    guard let end = period.end,
      !isCertain(component: .hour), dayPeriod == nil,
      !period.start.isCertain(component: .hour), !end.isCertain(component: .hour)
    else { throw .unresolvedComposition }
    let calendar = resolvedCalendar
    guard case .unique(let first) = period.start.dateResolution,
      case .unique(let last) = end.dateResolution,
      let lower = calendar.dateInterval(of: .day, for: first.instant)?.start,
      let upper = calendar.dateInterval(of: .day, for: last.instant)?.end,
      lower < upper
    else { throw .invalidComponents }
    return try resolvingDate(
      in: ParsedCalendarContext(
        calendar: calendar, interval: DateInterval(start: lower, end: upper)))
  }

  func resolvingDate(in context: ParsedCalendarContext) throws(ParsedDateIssue) -> Self {
    guard resolvedCalendar == context.calendar else { throw .invalidTimeZone }
    var resolved = self
    let calendar = context.calendar
    let lower = context.interval.start
    let upper = context.interval.end

    let unit: Calendar.Component
    if isCertain(component: .day) || isCertain(component: .weekday) {
      unit = .day
    } else if isCertain(component: .month) {
      unit = .month
    } else if isCertain(component: .year) {
      unit = .year
    } else {
      throw .unresolvedComposition
    }

    var matching = DateComponents()
    matching.year = knownValues[.year]
    matching.month = knownValues[.month]
    matching.day = knownValues[.day]
    matching.weekday = knownValues[.weekday].map { $0 + 1 }
    // A noon anchor avoids requiring midnight on days whose first clock is later.
    matching.hour = 12
    matching.minute = 0
    matching.second = 0
    if unit == .month { matching.day = 1 }
    if unit == .year {
      matching.month = 1
      matching.day = 1
    }

    guard let boundary = calendar.dateInterval(of: unit, for: lower)?.start,
      let match = calendar.nextDate(
        after: boundary.addingTimeInterval(-1), matching: matching, matchingPolicy: .strict),
      let bucket = calendar.dateInterval(of: unit, for: match),
      bucket.start >= lower, bucket.end <= upper
    else { throw .invalidComponents }
    if let second = calendar.nextDate(after: match, matching: matching, matchingPolicy: .strict),
      second < upper
    {
      throw .unresolvedComposition
    }

    resolved.assign(.year, value: calendar.component(.year, from: match))
    if unit != .year { resolved.assign(.month, value: calendar.component(.month, from: match)) }
    if unit == .day { resolved.assign(.day, value: calendar.component(.day, from: match)) }
    // Month/year precision must retain their first-day anchor, not today's day.
    if unit != .day { resolved.imply(.day, to: 1) }
    if unit == .year { resolved.imply(.month, to: 1) }
    resolved.calendarContext = context
    return resolved
  }
}
