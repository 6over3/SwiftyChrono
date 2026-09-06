import Foundation

final class ExtractTimeZoneRefiner: Refiner {
  override func refine(text: String, results: [ParsedResult], opt: [OptionType: Int]) throws
    -> [ParsedResult]
  {
    try results.map { try Self.bindingZone(to: $0, in: text) }
  }

  static func bindingZone(to original: ParsedResult, in text: String) throws -> ParsedResult {
    var result = original
    guard !result.isMoveIndexMode else { return result }
    while let suffix = try ParsedTimeZoneSuffix.read(
      in: text.substring(from: result.index + result.text.utf16.count),
      hasClock: result.start.isCertain(component: .hour)
        || result.end?.isCertain(component: .hour) == true)
    {
      result.text += suffix.text
      result.tags[.extractTimeZoneRefiner] = true
      guard let zone = suffix.zone else {
        result.issues.append(.invalidTimeZone)
        continue
      }
      if var end = result.end {
        if let written = end.timeZone, written != zone {
          result.issues.append(.invalidTimeZone)
          continue
        }
        end.assign(timeZone: zone)
        result.end = end
        if result.start.timeZone == nil { result.start.assign(timeZone: zone) }
      } else if let written = result.start.timeZone, written != zone {
        result.issues.append(.invalidTimeZone)
      } else {
        result.start.assign(timeZone: zone)
      }
    }
    return result
  }
}

extension ParsedResult {
  /// One shared written zone can supply the reference context for the whole
  /// expression. Distinct endpoint zones must remain distinct.
  var sharedTimeZone: TimeZone? {
    let zones = Set([start.timeZone, end?.timeZone].compactMap { $0 })
    guard zones.count == 1 else { return nil }
    return zones.first
  }
}
