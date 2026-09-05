import Foundation

/// An exact amount, never an integer sentinel or a guess for an indefinite quantity.
enum RelativeDateAmount {
  case whole(Int)
  case half

  init(text: String, language: Language) throws {
    let value = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    if !value.isEmpty, value.utf8.allSatisfy({ (48...57).contains($0) }) {
      guard let number = Int(value) else { throw ChronoError.invalidDate }
      self = .whole(number)
      return
    }
    let words: [String: Int]
    let singles: Set<String>
    let halves: String
    switch language {
    case .english:
      words = EN_INTEGER_WORDS
      singles = ["a", "an"]
      halves = "half(?:\\s*an?)?"
    case .french:
      words = FR_INTEGER_WORDS
      singles = ["un", "une"]
      halves = "demi(?:\\s*|-)?"
    case .german:
      words = DE_INTEGER_WORDS
      singles = Set(DE_INTEGER1_WORDS.keys)
      halves = "(?:\(DE_INTEGER1_WORDS_PATTERN)\\s*)?halbe(?:n|s)?"
    case .spanish:
      words = [:]
      singles = ["un", "una"]
      halves = "medi[oa]"
    case .catalan:
      words = [:]
      singles = ["un", "una"]
      halves = "mig|mitja"
    case .russian:
      words = RU_INTEGER_WORDS
      singles = ["один", "одну"]
      halves = "(?:один\\s*)?пол"
    case .chinese, .chineseSimplified:
      if value == "半" {
        self = .half
        return
      }
      let map = language == .chinese ? ZH_HANT_NUMBER : ZH_HANS_NUMBER
      self = .whole(try Self.chineseNumber(value, map: map))
      return
    case .neutral, .japanese:
      throw ChronoError.invalidDate
    }
    if let number = words[value] {
      self = .whole(number)
    } else if singles.contains(value) {
      self = .whole(1)
    } else if try NSRegularExpression.isMatch(forPattern: "^(?:\(halves))$", in: value) {
      self = .half
    } else {
      throw ChronoError.invalidDate
    }
  }

  // These grammars admit Chinese units through tens only. Reject malformed
  // repetitions rather than adding every character or converting unknowns to zero.
  private static func chineseNumber(_ text: String, map: [String: Int]) throws -> Int {
    let digits = try text.map { character -> Int in
      guard let value = map[String(character)] else { throw ChronoError.invalidDate }
      return value
    }
    switch digits.count {
    case 1: return digits[0]
    case 2:
      if [10, 20, 30].contains(digits[0]), (1...9).contains(digits[1]) {
        return digits[0] + digits[1]
      }
      if (1...9).contains(digits[0]), digits[1] == 10 { return digits[0] * 10 }
    case 3:
      if (1...9).contains(digits[0]), digits[1] == 10, (1...9).contains(digits[2]) {
        return digits[0] * 10 + digits[2]
      }
    default: break
    }
    throw ChronoError.invalidDate
  }
}
