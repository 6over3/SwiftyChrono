/// Registered grammar families, not a claim that every sentence in a language is understood.
public enum TemporalGrammarFeature: Hashable, Sendable {
  case isoDates
  case localizedDatesAndClocks
  case relativePeriods
  case comparisons
  case dayScopedClockComparisons
}
