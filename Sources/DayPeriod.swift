import Foundation

/// Semantic day-period identities from Unicode CLDR, separate from a clock guess.
struct DayPeriod: Equatable {
  enum Phase {
    case am, pm, morning1, morning2, afternoon1, afternoon2, evening1, night1, night2, noon,
      midnight
  }
  let phase: Phase
  let language: Language

  init(_ phase: Phase, language: Language) {
    self.phase = phase
    self.language = language
  }

  /// CLDR 48 dayPeriods.xml. Ranges describe local clock hours, not elapsed hours.
  /// Source: https://github.com/unicode-org/cldr/blob/release-48/common/supplemental/dayPeriods.xml
  /// Cross-midnight periods retain their upper day offset instead of widening to a day.
  func hours(in locale: Locale?) -> Range<Int>? {
    switch (language, phase) {
    case (_, .am): return 0..<12
    case (_, .pm): return 12..<24
    case (.english, .morning1): return 0..<12
    case (.english, .afternoon1): return 12..<18
    case (.english, .evening1): return 18..<21
    case (.english, .night1): return 21..<24
    case (.french, .morning1), (.russian, .morning1), (.japanese, .morning1): return 4..<12
    case (.french, .afternoon1), (.russian, .afternoon1): return 12..<18
    case (.french, .evening1), (.german, .evening1): return 18..<24
    case (.french, .night1): return 0..<4
    case (.german, .morning1): return 5..<10
    case (.german, .morning2): return 10..<12
    case (.german, .afternoon1), (.catalan, .afternoon1): return 12..<13
    case (.german, .afternoon2): return 13..<18
    case (.german, .night1): return 0..<5
    case (.spanish, .morning1), (.catalan, .morning1): return 0..<6
    case (.spanish, .morning2): return locale?.region?.identifier == "CO" ? 0..<12 : 6..<12
    case (.spanish, .evening1): return 12..<20
    case (.spanish, .night1): return 20..<24
    case (.catalan, .morning2): return 6..<12
    case (.catalan, .afternoon2): return 13..<19
    case (.catalan, .evening1): return 19..<21
    case (.catalan, .night1): return 21..<24
    case (.russian, .evening1): return 18..<22
    case (.russian, .night1): return 22..<28
    case (.japanese, .afternoon1): return 12..<16
    case (.japanese, .evening1): return 16..<19
    case (.japanese, .night1): return 19..<23
    case (.japanese, .night2): return 23..<28
    case (.chinese, .morning1), (.chineseSimplified, .morning1): return 5..<8
    case (.chinese, .morning2), (.chineseSimplified, .morning2): return 8..<12
    case (.chinese, .afternoon1), (.chineseSimplified, .afternoon1): return 12..<13
    case (.chinese, .afternoon2), (.chineseSimplified, .afternoon2): return 13..<19
    case (.chinese, .evening1), (.chineseSimplified, .evening1): return 19..<24
    case (.chinese, .night1), (.chineseSimplified, .night1): return 0..<5
    default: return nil
    }
  }
}
