import Foundation

final class TemporalComparisonRefiner: Refiner {
  private let grammar: Language
  override var language: Language { grammar }

  init(language: Language) { grammar = language }

  override func refine(text: String, results: [ParsedResult], opt: [OptionType: Int]) throws
    -> [ParsedResult]
  {
    try results.map { original in
      guard
        let binding = try TemporalComparisonGrammar.binding(
          to: NSRange(location: original.index, length: original.text.utf16.count),
          in: text, language: language)
      else { return original }
      var result = original
      result.index = binding.range.location
      result.text = try text.substring(from: result.index, to: NSMaxRange(binding.range))
      result.languages.insert(language)
      if result.comparison != nil || binding.comparison == .unresolved {
        result.issues.append(.unresolvedComposition)
      } else {
        result.comparison = binding.comparison
      }
      return result
    }
  }
}
