// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

/// A valid date interpretation whose wording also admits a non-date meaning.
public enum ParsedDateAmbiguity: Hashable, Sendable {
  case durationOrOffset
}

public struct ParsedResult {
  public let ref: ChronoDate
  /// UTF-16 offset into the original input, matching NSRegularExpression.
  public var index: Int
  public var text: String
  public var tags: [TagUnit: Bool]
  /// The grammars that actually contributed to the expression, including ISO syntax.
  public var languages: Set<Language> = []
  /// Recognized input that cannot be represented, retained rather than partially applied.
  public var issues: [ParsedDateIssue] = []
  /// Callers must not automatically filter by one interpretation of this wording.
  public var ambiguities: Set<ParsedDateAmbiguity> = []
  public var start: ParsedComponents
  public var end: ParsedComponents?
  let isMoveIndexMode: Bool

  public init(
    ref: ChronoDate, index: Int, text: String,
    tags: [TagUnit: Bool] = [:],
    start: [ComponentUnit: Int]? = nil,
    end: [ComponentUnit: Int]? = nil
  ) {
    self.ref = ref
    self.index = index
    self.text = text
    self.tags = tags
    self.start = ParsedComponents(components: start, ref: ref)
    self.end = end.map { ParsedComponents(components: $0, ref: ref) }
    isMoveIndexMode = false
  }

  private init(ref: ChronoDate, advancingTo index: Int) {
    self.ref = ref
    self.index = index
    text = ""
    tags = [:]
    start = ParsedComponents(components: nil, ref: ref)
    end = nil
    isMoveIndexMode = true
  }

  static func moveIndexMode(ref: ChronoDate, index: Int) -> ParsedResult {
    ParsedResult(ref: ref, advancingTo: index)
  }

  func clone() -> ParsedResult { self }

}
