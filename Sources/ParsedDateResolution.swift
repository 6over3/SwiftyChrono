import Foundation

/// A civil expression can name one instant, a repeated clock time, or no valid time.
/// Callers must not turn the first occurrence into an implicit interpretation.
public enum ParsedDateResolution {
  case unique(ChronoDate)
  case repeated(earlier: ChronoDate, later: ChronoDate)
  case invalid(ParsedDateIssue)

  var bounds: (earliest: Date, latest: Date)? {
    switch self {
    case .unique(let date): return (date.instant, date.instant)
    case .repeated(let earlier, let later): return (earlier.instant, later.instant)
    case .invalid: return nil
    }
  }
}

/// Invalid user input remains attached to its full parsed expression.
public enum ParsedDateIssue: Hashable {
  case invalidComponents
  case invalidTimeZone
  case nonexistentLocalTime
  case unsupportedPrecision
}
