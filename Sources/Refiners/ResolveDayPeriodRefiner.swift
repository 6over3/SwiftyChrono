import Foundation

final class ResolveDayPeriodRefiner: Refiner {
  override func refine(
    text: String, results: [ParsedResult], opt: [OptionType: Int]
  ) throws -> [ParsedResult] {
    try results.map { original in
      guard original.issues.isEmpty else { return original }
      var result = original
      do {
        let interval = try result.start.resolveDayPeriod()
        if let interval {
          let first = ChronoDate(instant: interval.start, calendar: result.start.resolvedCalendar)
          try result.start.assign(date: first, precision: .second)
        }
        if var end = result.end {
          if let interval = try end.resolveDayPeriod() {
            let last = ChronoDate(
              instant: interval.end.addingTimeInterval(-1), calendar: end.resolvedCalendar)
            try end.assign(date: last, precision: .second)
          }
          result.end = end
        } else if let interval {
          var end = result.start
          let last = ChronoDate(
            instant: interval.end.addingTimeInterval(-1), calendar: end.resolvedCalendar)
          try end.assign(date: last, precision: .second)
          result.end = end
        }
      } catch let issue as ParsedDateIssue {
        result = original
        result.issues.append(issue)
      }
      return result
    }
  }
}
