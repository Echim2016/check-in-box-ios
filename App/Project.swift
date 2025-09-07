import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "App",
  options: .options(
    automaticSchemesOptions: .enabled(codeCoverageEnabled: true),
    textSettings: .textSettings(
      usesTabs: false,
      indentWidth: 2,
      tabWidth: 2,
      wrapsLines: true
    )
  ),
  targets: [
    .target(
      name: Project.appName,
      destinations: [.iPhone, .iPad, .mac],
      product: .app,
      bundleId: Project.bundleId,
      deploymentTargets: .iOS(Project.minimumDeploymentVersion),
      infoPlist: .extendingDefault(
        with: [
          "ITSAppUsesNonExemptEncryption" : false,
          "UILaunchStoryboardName": "LaunchScreen",
          "CFBundleDisplayName": "Check-in Box",
          "CFBundleShortVersionString": .string(Project.bundleVersion),
        ]
      ),
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: [
        .composableArchitecture,
        .home,
        .firebaseServiceLive,
      ],
      settings: .settings(
        base: .init()
          .automaticCodeSigning(devTeam: "$(XCC_DEV_TEAM_ID)")
          .marketingVersion(Project.bundleVersion)
          .currentProjectVersion(Project.buildNumber),
        configurations: [
          .debug(
            name: .configuration("debug"),
            xcconfig: .relativeToRoot("App/Sources/Configurations/debug.xcconfig")
          ),
          .release(
            name: .configuration("release"),
            xcconfig: .relativeToRoot("App/Sources/Configurations/release.xcconfig")
          ),
        ],
        defaultSettings: .recommended
      )
    ),
    .target(
      name: "AppTests",
      destinations: [.iPhone],
      product: .unitTests,
      bundleId: "\(Project.bundleId)Tests",
      sources: ["Tests/**"],
      resources: [],
      dependencies: [.target(name: Project.appName)]
    ),
  ],
  schemes: [
    .debug,
    .release
  ]
)
