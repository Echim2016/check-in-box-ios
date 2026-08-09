// swift-tools-version: 6.0
import PackageDescription

#if TUIST
  import struct ProjectDescription.PackageSettings

  let packageSettings = PackageSettings(
    productTypes: [
      "ComposableArchitecture": .framework,
      "Sharing": .framework,
    ]
  )
#endif

let package = Package(
  name: "check-in-box-ios",
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      exact: "1.26.1"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-sharing.git",
      exact: "2.9.1"
    ),
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk",
      exact: "12.17.0"
    ),
    .package(
      url: "https://github.com/onevcat/Kingfisher.git",
      exact: "8.11.0"
    ),
  ]
)
