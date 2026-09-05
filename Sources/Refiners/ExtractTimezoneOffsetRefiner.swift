// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

class ExtractTimezoneOffsetRefiner: Refiner {
  override public func refine(
    text: String, results: [ParsedResult], opt: [OptionType: Int]
  ) throws -> [ParsedResult] {
    // Capture the complete offset-shaped token, including malformed suffixes.
    // Bare minus words are not time zones. Do not bind across a line break.
    let regex = try NSRegularExpression(
      pattern: #"^[\t ]*(\(?(?:(?:GMT|UTC)[+-][^\s,;!?)\]}]*|[+-][0-9][^\s,;!?)\]}]*))"#,
      options: .caseInsensitive)
    return try results.map { original in
      var result = original
      let suffix = try text.substring(from: result.index + result.text.utf16.count)
      guard
        let match = regex.firstMatch(
          in: suffix, range: NSRange(location: 0, length: suffix.utf16.count))
      else { return result }
      var token = try match.string(from: suffix, atRangeIndex: 1)
      let unwrapped = token.first == "(" ? token.dropFirst() : token[...]
      let prefix = unwrapped.prefix(3).uppercased()
      // A bare hyphen after a date may introduce a date range, not a zone.
      guard
        result.start.isCertain(component: .hour)
          || result.end?.isCertain(component: .hour) == true || prefix == "GMT" || prefix == "UTC"
      else { return result }
      var consumed = try match.string(from: suffix, atRangeIndex: 0)
      if token.first == "(", suffix.utf16.dropFirst(match.range.length).first == 0x29 {
        token += ")"
        consumed += ")"
      }
      result.text += consumed
      result.tags[.extractTimezoneOffsetRefiner] = true
      guard let offset = offset(in: token) else {
        result.issues.append(.invalidTimeZone)
        return result
      }
      if var end = result.end {
        if end.isCertain(component: .timeZoneOffset), end[.timeZoneOffset] != offset {
          result.issues.append(.invalidTimeZone)
        } else {
          end.assign(.timeZoneOffset, value: offset)
          result.end = end
          if !result.start.isCertain(component: .timeZoneOffset) {
            result.start.assign(.timeZoneOffset, value: offset)
          }
        }
      } else if result.start.isCertain(component: .timeZoneOffset),
        result.start[.timeZoneOffset] != offset
      {
        result.issues.append(.invalidTimeZone)
      } else {
        result.start.assign(.timeZoneOffset, value: offset)
      }
      return result
    }
  }

  private func offset(in token: String) -> Int? {
    var value = token[...]
    if value.first == "(" {
      guard value.last == ")" else { return nil }
      value = value.dropFirst().dropLast()
    }
    if value.prefix(3).uppercased() == "GMT" || value.prefix(3).uppercased() == "UTC" {
      value = value.dropFirst(3)
    }
    return parsedTimeZoneOffset(String(value))
  }
}
