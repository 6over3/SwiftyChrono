import Foundation

/// The written relation to a date period or clock point, before choosing filter bounds.
public enum TemporalComparison: Hashable, Sendable {
  case before, after, since, through, unresolved
}

/// Includes both the operand and its attached comparison wording in UTF-16 coordinates.
public struct TemporalComparisonBinding: Sendable {
  public let comparison: TemporalComparison
  public let range: NSRange
}

/// Shared native comparison vocabulary for date composition and external date operands.
/// This can bind to a season supplied by a caller without implementing seasons twice.
public enum TemporalComparisonGrammar {
  public static func binding(
    to operand: NSRange, in text: String, language: Language
  ) throws -> TemporalComparisonBinding? {
    guard let operandRange = Range(operand, in: text) else { throw ChronoError.invalidSourceRange }
    let matches = try matches(in: text, language: language)
    var lower = operandRange.lowerBound
    var upper = operandRange.upperBound
    var selected: [TemporalComparison] = []
    for match in matches.filter({ !$0.suffix }).sorted(by: {
      $0.range.upperBound > $1.range.upperBound
    }) {
      guard match.range.upperBound <= lower,
        text[match.range.upperBound..<lower].allSatisfy(\.isWhitespace)
      else { continue }
      lower = match.range.lowerBound
      selected.append(match.comparison)
    }
    for match in matches.filter(\.suffix).sorted(by: { $0.range.lowerBound < $1.range.lowerBound })
    {
      guard match.range.lowerBound >= upper,
        text[upper..<match.range.lowerBound].allSatisfy(\.isWhitespace)
      else { continue }
      upper = match.range.upperBound
      selected.append(match.comparison)
    }
    guard let comparison = selected.first else { return nil }
    return TemporalComparisonBinding(
      comparison: selected.count == 1 ? comparison : .unresolved,
      range: NSRange(lower..<upper, in: text))
  }

  /// Recognize a complete connector between a date and clock, not a word inside prose.
  static func connector(in text: String, language: Language) throws -> TemporalComparison? {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard
      let binding = try binding(
        to: NSRange(location: trimmed.utf16.count, length: 0), in: trimmed, language: language),
      binding.range == NSRange(trimmed.startIndex..., in: trimmed)
    else { return nil }
    return binding.comparison
  }

  /// A bare number is not a clock. Retain its uncertainty when a comparison
  /// connects it to another date, so that date cannot escape as a smaller filter.
  static func unresolvedClock(_ original: ParsedResult, in text: String, language: Language)
    throws -> ParsedResult?
  {
    guard
      try binding(
        to: NSRange(location: original.index, length: original.text.utf16.count),
        in: text, language: language) != nil
    else { return nil }
    var result = original
    result.issues.append(.unresolvedComposition)
    return result
  }

  private struct Match {
    let comparison: TemporalComparison
    let range: Range<String.Index>
    let suffix: Bool
  }

  private static func matches(in text: String, language: Language) throws -> [Match] {
    try rules(for: language).flatMap { rule in
      let regex = try NSRegularExpression(pattern: rule.pattern, options: [.caseInsensitive])
      return try regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).map {
        guard let range = Range($0.range, in: text) else { throw ChronoError.invalidSourceRange }
        return Match(comparison: rule.comparison, range: range, suffix: rule.suffix)
      }
    }
  }
}
