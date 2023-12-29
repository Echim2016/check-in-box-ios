// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Features",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Features",
      targets: ["Features"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.5.5"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "10.18.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Features",
      dependencies: [.tca, .firebaseFirestore, .firebaseFirestoreSwift, .firebaseRemoteConfig, .firebaseAnalytics, .firebaseCrashlytics, .kingfisher]
    ),
    .testTarget(
      name: "FeaturesTests",
      dependencies: ["Features", .tca]
    ),
  ]
)

extension Target.Dependency {
  static let tca = Self.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
  static let firebaseFirestore = Self.product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
  static let firebaseFirestoreSwift = Self.product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk")
  static let firebaseRemoteConfig = Self.product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk")
  static let firebaseAnalytics = Self.product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
  static let firebaseCrashlytics = Self.product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
  static let kingfisher = Self.product(name: "Kingfisher", package: "Kingfisher")
}
