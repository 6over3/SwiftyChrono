// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

func sortTwoNumbers(_ first: Int, _ second: Int) -> (lessNumber: Int, greaterNumber: Int) {
  (min(first, second), max(first, second))
}

extension NSTextCheckingResult {
  func isNotEmpty(atRangeIndex index: Int) -> Bool { range(at: index).length != 0 }
  func isEmpty(atRangeIndex index: Int) -> Bool { range(at: index).length == 0 }

  func string(from text: String, atRangeIndex index: Int) throws -> String {
    let captured = range(at: index)
    // An optional capture which did not participate is not a source error.
    guard captured.location != NSNotFound else { return "" }
    return try text.subString(with: captured)
  }
}

extension String {
  var firstString: String? { first.map(String.init) }

  func character(beforeUTF16Offset offset: Int) throws -> String? {
    guard offset >= 0, offset <= utf16.count,
      let index = String.Index(utf16.index(utf16.startIndex, offsetBy: offset), within: self)
    else { throw ChronoError.invalidSourceRange }
    guard index != startIndex else { return nil }
    return String(self[self.index(before: index)..<index])
  }

  func subString(with range: NSRange) throws -> String {
    guard range.location >= 0, range.length >= 0,
      range.location <= utf16.count, range.length <= utf16.count - range.location,
      let indices = Range(range, in: self)
    else { throw ChronoError.invalidSourceRange }
    return String(self[indices])
  }

  func substring(from offset: Int) throws -> String {
    try substring(from: offset, to: utf16.count)
  }

  func substring(from start: Int, to end: Int) throws -> String {
    guard start >= 0, end >= start else { throw ChronoError.invalidSourceRange }
    return try subString(with: NSRange(location: start, length: end - start))
  }

  func range(ofStartIndex start: Int, length: Int) throws -> Range<String.Index> {
    guard start >= 0, length >= 0, start <= utf16.count, length <= utf16.count - start,
      let range = Range(NSRange(location: start, length: length), in: self)
    else { throw ChronoError.invalidSourceRange }
    return range
  }

  func range(ofStartIndex start: Int, andEndIndex end: Int) throws -> Range<String.Index> {
    guard start >= 0, end >= start else { throw ChronoError.invalidSourceRange }
    return try range(ofStartIndex: start, length: end - start)
  }

  func trimmed() -> String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

extension NSRegularExpression {
  static func isMatch(forPattern pattern: String, in text: String) throws -> Bool {
    let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    return regex.firstMatch(in: text, range: NSRange(location: 0, length: text.utf16.count)) != nil
  }
}

extension Dictionary {
  mutating func merge(with dictionary: Dictionary) {
    dictionary.forEach { updateValue($1, forKey: $0) }
  }

  func merged(with dictionary: Dictionary) -> Dictionary {
    var result = self
    result.merge(with: dictionary)
    return result
  }
}
