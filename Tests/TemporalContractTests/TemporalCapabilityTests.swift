import Testing

@testable import SwiftyChrono

@Suite("Reported temporal grammar matches registered components")
struct TemporalCapabilityTests {
  @Test("Strict parsing does not claim casual relative periods")
  func strictAndCasual() throws {
    let strict = Chrono(strict: true).languageCapabilities
    let casual = Chrono().languageCapabilities
    #expect(strict[.neutral] == [.isoDates])
    #expect(casual[.neutral] == [.isoDates])
    for language in Language.allCases where language != .neutral {
      let strictFeatures = try #require(strict[language])
      let casualFeatures = try #require(casual[language])
      #expect(strictFeatures.contains(.localizedDatesAndClocks))
      #expect(!strictFeatures.contains(.relativePeriods))
      #expect(casualFeatures.contains(.relativePeriods))
      #expect(casualFeatures.contains(.comparisons))
    }
  }

  @Test("Day-scoped clock comparisons are reported only for registered composers")
  func clockScopeCoverage() {
    let capabilities = Chrono().languageCapabilities
    let supported = Set(
      capabilities.compactMap { language, features in
        features.contains(.dayScopedClockComparisons) ? language : nil
      })
    #expect(supported == [.english, .french, .german, .russian, .spanish, .catalan])
  }
}
