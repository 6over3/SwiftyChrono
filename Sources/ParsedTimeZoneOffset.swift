// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

/// Complete signed numeric offsets. Values are minutes, not locale-formatted numbers.
func parsedTimeZoneOffset(_ text: String) -> Int? {
  guard let sign = text.utf8.first, sign == 0x2b || sign == 0x2d else { return nil }
  let body = text.dropFirst()
  let parts = body.split(separator: ":", omittingEmptySubsequences: false)
  let hoursText: Substring
  let minutesText: Substring
  if parts.count == 2 {
    hoursText = parts[0]
    minutesText = parts[1]
    guard minutesText.utf8.count == 2 else { return nil }
  } else if parts.count == 1 {
    switch body.utf8.count {
    case 1, 2:
      hoursText = body
      minutesText = "00"  // A written whole-hour offset.
    case 3, 4:
      hoursText = body.dropLast(2)
      minutesText = body.suffix(2)
    default:
      return nil
    }
  } else {
    return nil
  }
  guard (1...2).contains(hoursText.utf8.count),
    hoursText.utf8.allSatisfy({ (0x30...0x39).contains($0) }),
    minutesText.utf8.allSatisfy({ (0x30...0x39).contains($0) }),
    let hours = Int(hoursText), let minutes = Int(minutesText),
    hours <= 23, minutes <= 59
  else { return nil }
  let offset = (sign == 0x2d ? -1 : 1) * (hours * 60 + minutes)
  guard TimeZone(secondsFromGMT: offset * 60) != nil else { return nil }
  return offset
}
