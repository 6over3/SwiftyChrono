import Foundation

/// Zone syntax is language-neutral. Abbreviations identify possible zones, not
/// a permanent offset or an authoritative choice of geopolitical region.
struct ParsedTimeZoneSuffix {
  let text: String
  let zone: TimeZone?
  private static let expression = Result {
    try NSRegularExpression(
      pattern:
        #"^[\t ]*(\()?((?:(?:GMT|UTC)[+-]|[+-][0-9])[^\s,;!?)\]}]*|[A-Z][A-Z0-9_.+-]*(?:/[A-Z0-9_.+-]*)+|[A-Z]{2,6}(?![A-Z0-9_]))"#,
      options: .caseInsensitive)
  }

  static func read(in suffix: String, hasClock: Bool) throws -> Self? {
    let regex = try expression.get()
    guard
      let match = regex.firstMatch(
        in: suffix, range: NSRange(location: 0, length: suffix.utf16.count))
    else { return nil }
    let token = try match.string(from: suffix, atRangeIndex: 2)
    let upper = token.uppercased()
    let zone: TimeZone?
    if upper.hasPrefix("UTC+") || upper.hasPrefix("UTC-")
      || upper.hasPrefix("GMT+") || upper.hasPrefix("GMT-")
    {
      zone = fixedOffset(String(token.dropFirst(3)))
    } else if token.first == "+" || token.first == "-" {
      // A bare hyphen after a date can introduce the next date in a range.
      guard hasClock else { return nil }
      zone = fixedOffset(token)
    } else if upper == "UTC" || upper == "GMT" {
      zone = TimeZone(secondsFromGMT: 0)
    } else if token.contains("/") {
      zone = TimeZone(identifier: token)
    } else {
      guard TimeZone.abbreviationDictionary[upper] != nil else { return nil }
      zone = nil
    }
    var consumed = try match.string(from: suffix, atRangeIndex: 0)
    if match.isNotEmpty(atRangeIndex: 1) {
      guard suffix.utf16.dropFirst(match.range.length).first == 0x29 else {
        return Self(text: consumed, zone: nil)
      }
      consumed += ")"
    }
    return Self(text: consumed, zone: zone)
  }

  private static func fixedOffset(_ text: String) -> TimeZone? {
    guard let minutes = parsedTimeZoneOffset(text) else { return nil }
    return TimeZone(secondsFromGMT: minutes * 60)
  }
}
