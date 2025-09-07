//
//  TargetDependency+Helpers.swift
//  Packages
//
//  Created by Yi-Chin Hsu on 2025/9/6.
//

import ProjectDescription

public extension TargetDependency {
  // external
  static let composableArchitecture: TargetDependency = .external(name: "ComposableArchitecture")
  static let firebaseFirestore: TargetDependency = .external(name: "FirebaseFirestore")
  static let firebaseAnalytics: TargetDependency = .external(name: "FirebaseAnalytics")
  static let firebaseRemoteConfig: TargetDependency = .external(name: "FirebaseRemoteConfig")
  static let kingfisher: TargetDependency = .external(name: "Kingfisher")
  
  // project
  static let home: TargetDependency = .project(target: "Home", path: .relativeToRoot("Home"))
  static let cbFoundation: TargetDependency = .project(target: "CBFoundation", path: .relativeToRoot("CBFoundation"))
  static let firebaseService: TargetDependency = .project(target: "FirebaseService", path: .relativeToRoot("FirebaseService"))
  static let firebaseServiceLive: TargetDependency = .project(target: "FirebaseServiceLive", path: .relativeToRoot("FirebaseServiceLive"))

}

public extension Project {
  static let bundleId = "com.echim.check-in-box-ios"
  static let appName = "check-in-box"
  static let minimumDeploymentVersion = "17.0"
  static let bundleVersion = "1.3.0"
  static let buildNumber = "1"
}
