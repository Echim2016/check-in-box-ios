// swift-tools-version: 6.0
import PackageDescription

#if TUIST
  import struct ProjectDescription.PackageSettings

  let packageSettings = PackageSettings(
    productTypes: [
      "ComposableArchitecture": .framework,
    ]
  )
#endif

let package = Package(
  name: "check-in-box-ios",
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      exact: "1.22.2"
    ),
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk",
      exact: "12.2.0"
    ),
    .package(
      url: "https://github.com/onevcat/Kingfisher.git",
      exact: "8.2.0"
    ),
  ]
)
