// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

public class Parser {
  let strictMode: Bool
  var pattern: String { "" }
  var language: Language { .english }

  public init(strictMode: Bool) { self.strictMode = strictMode }

  public func extract(
    text: String, ref: ChronoDate, match: NSTextCheckingResult, opt: [OptionType: Int]
  ) throws -> ParsedResult? { nil }

  public func execute(text: String, ref: ChronoDate, opt: [OptionType: Int]) throws
    -> [ParsedResult]
  {
    let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    var results: [ParsedResult] = []
    let length = text.utf16.count
    var offset = 0
    while offset < length,
      let match = regex.firstMatch(
        in: text, range: NSRange(location: offset, length: length - offset))
    {
      let result: ParsedResult?
      do {
        result = try extractWithTimeZone(text: text, ref: ref, match: match, opt: opt)
      } catch ChronoError.invalidDate {
        var rejected = ParsedResult(
          ref: ref, index: match.range.location, text: try match.string(from: text, atRangeIndex: 0)
        )
        rejected.issues = [.invalidComponents]
        result = try ExtractTimeZoneRefiner.bindingZone(to: rejected, in: text)
      }
      if var result {
        result.languages.insert(language)
        let end = result.index.addingReportingOverflow(result.text.utf16.count)
        guard !end.overflow, end.partialValue > offset, end.partialValue <= length,
          result.index >= offset
        else { throw ChronoError.invalidSourceRange }
        offset = end.partialValue
        if !result.isMoveIndexMode { results.append(result) }
      } else {
        // Advance on a valid String boundary, never into a surrogate pair.
        guard let range = Range(match.range, in: text), range.lowerBound < text.endIndex
        else { throw ChronoError.invalidSourceRange }
        let next = text.index(after: range.lowerBound)
        offset = next.utf16Offset(in: text)
      }
    }
    return results
  }

  final func matchTextAndIndex(
    from text: String, andMatchResult match: NSTextCheckingResult
  ) throws -> (matchText: String, index: Int) {
    let leadingLength = match.range(at: 1).length
    let value = try match.string(from: text, atRangeIndex: 0).substring(from: leadingLength)
    return (value, match.range.location + leadingLength)
  }

  final func matchTextAndIndexForCHHant(
    from text: String, andMatchResult match: NSTextCheckingResult
  ) throws -> (matchText: String, index: Int) {
    (try match.string(from: text, atRangeIndex: 0), match.range.location)
  }
}
