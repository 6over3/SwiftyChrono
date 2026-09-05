import Foundation

/// Invalid user date values are distinct from inconsistent parser coordinates.
public enum ChronoError: Error {
  case invalidDate
  case invalidSourceRange
  case invalidCalendar
}
