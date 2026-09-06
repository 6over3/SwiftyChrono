import Foundation

extension Parser {
  /// Re-evaluate the same grammar match in its written zone before composition.
  /// Relabeling fields computed in the reference zone would change their meaning.
  func extractWithTimeZone(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? {
    guard let raw = try extract(text: text, ref: ref, match: match, opt: opt) else { return nil }
    var bound = try ExtractTimeZoneRefiner.bindingZone(to: raw, in: text)
    guard bound.issues.isEmpty, let zone = bound.sharedTimeZone, zone != ref.calendar.timeZone
    else { return bound }
    var calendar = ref.calendar
    calendar.timeZone = zone
    let reference = ChronoDate(instant: ref.instant, calendar: calendar)
    do {
      guard let recalculated = try extract(text: text, ref: reference, match: match, opt: opt)
      else {
        bound.issues.append(.invalidTimeZone)
        return bound
      }
      return try ExtractTimeZoneRefiner.bindingZone(to: recalculated, in: text)
    } catch ChronoError.invalidDate {
      bound.issues.append(.invalidComponents)
      return bound
    }
  }
}
