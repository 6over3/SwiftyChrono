import Foundation

extension ParsedComponents {
  /// Share only omitted context. Written endpoint dates and precision are retained.
  static func resolvingRange(start: Self, end: Self) throws(ParsedDateIssue)
    -> (start: Self, end: Self)
  {
    var first = try start.inheritingRangeContext(from: end)
    var last = try end.inheritingRangeContext(from: start)
    let firstHasYear = start.isCertain(component: .year)
    let lastHasYear = end.isCertain(component: .year)
    guard firstHasYear != lastHasYear,
      let firstMonth = start.knownValues[.month], let lastMonth = end.knownValues[.month]
    else { return (first, last) }

    let crossesYear: Bool
    if firstMonth == lastMonth,
      let firstDay = start.knownValues[.day], let lastDay = end.knownValues[.day]
    {
      crossesYear = firstDay > lastDay
    } else {
      crossesYear = firstMonth > lastMonth
    }
    guard crossesYear, first.calendarContext == nil, last.calendarContext == nil else {
      return (first, last)
    }
    // December–January shares the written year across New Year, not a backwards
    // interval. Never shift an explicitly supplied year or a qualified week.
    if firstHasYear {
      guard let year = last[.year], (1..<9999).contains(year) else { throw .invalidComponents }
      last.assign(.year, value: year + 1)
    } else {
      guard let year = first[.year], (2...9999).contains(year) else { throw .invalidComponents }
      first.assign(.year, value: year - 1)
    }
    guard first.dateResolution.bounds != nil, last.dateResolution.bounds != nil else {
      throw .invalidComponents
    }
    return (first, last)
  }

  private func inheritingRangeContext(from source: Self) throws(ParsedDateIssue) -> Self {
    if !isCertain(component: .year), let context = source.calendarContext,
      [ComponentUnit.month, .day, .weekday].contains(where: { isCertain(component: $0) })
    {
      return try resolvingDate(in: context)
    }
    if isCertain(component: .weekday), !isCertain(component: .day) {
      return self
    }
    // A bare weekday is not a supplied date for the other endpoint.
    if source.isCertain(component: .weekday), !source.isCertain(component: .day) { return self }
    let fields: [ComponentUnit]
    if isCertain(component: .day) || isCertain(component: .hour) {
      fields = [.year, .month, .day]
    } else if isCertain(component: .month) {
      fields = [.year]
    } else {
      return self
    }
    var resolved = self
    for field in fields where !isCertain(component: field) {
      if let value = source.knownValues[field] { resolved.assign(field, value: value) }
    }
    return resolved
  }
}
