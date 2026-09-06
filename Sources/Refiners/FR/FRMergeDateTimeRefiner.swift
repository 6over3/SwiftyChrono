// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
import Foundation

final class FRMergeDateTimeRefiner: MergeDateTimeRefiner {
  override var language: Language { .french }
  override var PATTERN: String { #"^\s*(T|à|a|vers|de|,|-)?\s*$"# }
  override var TAGS: TagUnit { .frMergeDateAndTimeRefiner }
}
