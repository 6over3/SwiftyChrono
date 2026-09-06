import Foundation

enum WeekdayReference { case nearest, previousWeek, nextWeek, currentWeek }

extension ParsedComponents {
  /// The unqualified weekday uses the same nearest occurrence in every grammar.
  mutating func assignWeekday(
    _ offset: Int, relativeTo ref: ChronoDate, reference: WeekdayReference
  ) throws {
    guard (0...6).contains(offset) else { throw ChronoError.invalidDate }
    let weekday: Int
    switch reference {
    case .previousWeek: weekday = offset - 7
    case .nextWeek: weekday = offset + 7
    case .currentWeek: weekday = offset
    case .nearest:
      if abs(offset - 7 - ref.weekday) < abs(offset - ref.weekday) {
        weekday = offset - 7
      } else if abs(offset + 7 - ref.weekday) < abs(offset - ref.weekday) {
        weekday = offset + 7
      } else {
        weekday = offset
      }
    }
    let date = try ref.setOrAdded(weekday, .weekday)
    assign(.weekday, value: offset)
    for (unit, value) in [(ComponentUnit.year, date.year), (.month, date.month), (.day, date.day)] {
      switch reference {
      case .previousWeek, .nextWeek: assign(unit, value: value)
      case .nearest, .currentWeek: imply(unit, to: value)
      }
    }
  }
}
