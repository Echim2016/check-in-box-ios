import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "FirebaseService",
  targets: [
    .target(
      name: "FirebaseService",
      destinations: [.iPhone, .iPad, .mac],
      product: .framework,
      bundleId: "\(Project.bundleId).FirebaseService",
      deploymentTargets: .iOS(Project.minimumDeploymentVersion),
      sources: ["Sources/**"],
      resources: nil,
      dependencies: [
        .composableArchitecture,
        .cbFoundation,
      ],
    ),
    .target(
      name: "FirebaseServiceTests",
      destinations: [.iPhone],
      product: .unitTests,
      bundleId: "\(Project.bundleId).FirebaseServiceTests",
      deploymentTargets: .iOS("17.0"),
      sources: ["Tests/**"],
      dependencies: [.target(name: "FirebaseService")]
    ),
  ]
)
