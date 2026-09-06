import Foundation

let ES_INTEGER_WORDS = [
  "cero": 0, "uno": 1, "una": 1, "un": 1, "dos": 2, "tres": 3, "cuatro": 4,
  "cinco": 5, "seis": 6, "siete": 7, "ocho": 8, "nueve": 9, "diez": 10,
  "once": 11, "doce": 12,
]
let CA_INTEGER_WORDS = [
  "zero": 0, "un": 1, "una": 1, "dos": 2, "dues": 2, "tres": 3, "quatre": 4,
  "cinc": 5, "sis": 6, "set": 7, "vuit": 8, "nou": 9, "deu": 10,
  "onze": 11, "dotze": 12,
]
let ES_INTEGER_WORDS_PATTERN = integerWordsPattern(ES_INTEGER_WORDS)
let CA_INTEGER_WORDS_PATTERN = integerWordsPattern(CA_INTEGER_WORDS)

private func integerWordsPattern(_ words: [String: Int]) -> String {
  "(?:"
    + words.keys.sorted { $0.count == $1.count ? $0 < $1 : $0.count > $1.count }
    .map(NSRegularExpression.escapedPattern).joined(separator: "|") + ")"
}
