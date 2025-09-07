//
//  Scheme+Helpers.swift
//  ProjectDescriptionHelpers
//
//  Created by Yi-Chin Hsu on 2025/9/6.
//

import Foundation
import ProjectDescription

public extension Scheme {
  static let debug: Scheme = .scheme(
    name: "check-in-box-debug",
    shared: true,
    buildAction: .buildAction(
      targets: ["\(Project.appName)"],
    ),
    testAction: .testPlans(
      [
        .relativeToRoot("App/Tests/AppTests.xctestplan"),
      ],
      configuration: .debug
    ),
    runAction: .runAction(
      configuration: .debug,
      arguments: .arguments(
        launchArguments: [
          .launchArgument(name: "-FIRDebugEnabled", isEnabled: true),
          .launchArgument(name: "-FIRAnalyticsDebugEnabled", isEnabled: true),
        ]
      )
    ),
    archiveAction: .archiveAction(configuration: .debug),
    profileAction: .profileAction(configuration: .debug),
    analyzeAction: .analyzeAction(configuration: .debug)
  )
  
  static let release: Scheme = .scheme(
    name: "check-in-box-release",
    shared: true,
    buildAction: .buildAction(
      targets: ["\(Project.appName)"],
    ),
    testAction: .testPlans(
      [
        .relativeToRoot("App/Tests/AppTests.xctestplan"),
      ],
      configuration: .release
    ),
    runAction: .runAction(
      configuration: .release,
      arguments: .arguments(
        launchArguments: [
          .launchArgument(name: "-FIRDebugEnabled", isEnabled: true),
        ]
      )
    ),
    archiveAction: .archiveAction(configuration: .release),
    profileAction: .profileAction(configuration: .release),
    analyzeAction: .analyzeAction(configuration: .release)
  )
}

