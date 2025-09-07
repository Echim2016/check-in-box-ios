import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Home",
  targets: [
    .target(
      name: "Home",
      destinations: [.iPhone, .iPad, .mac],
      product: .framework,
      bundleId: "\(Project.bundleId).Home",
      deploymentTargets: .iOS(Project.minimumDeploymentVersion),
      sources: ["Sources/**"],
      resources: nil,
      dependencies: [
        .composableArchitecture,
        .cbFoundation,
        .kingfisher,
        .firebaseService,
      ],
      settings: .settings(
        base: [:]
      )
    ),
    .target(
      name: "HomeTests",
      destinations: [.iPhone],
      product: .unitTests,
      bundleId: "\(Project.bundleId).HomeTests",
      deploymentTargets: .iOS("17.0"),
      sources: ["Tests/**"],
      dependencies: [.target(name: "Home")]
    ),
  ]
)
