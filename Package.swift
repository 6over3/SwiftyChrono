// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftyChrono",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .watchOS(.v9),
  ],
  products: [
    .library(
      name: "SwiftyChrono",
      targets: ["SwiftyChrono"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "SwiftyChrono",
      dependencies: [],
      path: "Sources"),
    .testTarget(
      name: "TemporalContractTests",
      dependencies: ["SwiftyChrono"],
      path: "Tests/TemporalContractTests"),
    .testTarget(
      name: "SwiftyChronoTests",
      dependencies: ["SwiftyChrono"],
      path: "Tests/SwiftyChronoTests",
      resources: [.copy("JS")]),
  ],
  swiftLanguageModes: [.v5]
)
