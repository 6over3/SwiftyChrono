.PHONY: temporal-test

# Focused native contracts; the historical JavaScript fixtures are independent.
temporal-test:
	swift build --target TemporalContractTests
	@set -eu; temporal_bundle="$(abspath .build/out/Products/Debug/TemporalContractTests.xctest/Contents/MacOS/TemporalContractTests)"; \
	helper="$$(dirname "$$(xcrun --find swift)")/../libexec/swift/pm/swiftpm-testing-helper"; \
	developer="$$(xcrun --sdk macosx --show-sdk-platform-path)/Developer"; \
	test -x "$$temporal_bundle"; \
	env DYLD_FRAMEWORK_PATH="$$developer/Library/Frameworks" DYLD_LIBRARY_PATH="$$developer/usr/lib" \
		"$$helper" --test-bundle-path "$$temporal_bundle" --package-path . \
		"$$temporal_bundle" --testing-library swift-testing
