import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "CBFoundation",
  targets: [
    .target(
      name: "CBFoundation",
      destinations: [.iPhone, .iPad, .mac],
      product: .framework,
      bundleId: "\(Project.bundleId).CBFoundation",
      deploymentTargets: .iOS(Project.minimumDeploymentVersion),
      sources: ["Sources/**"],
      resources: nil,
      dependencies: [],
    ),
    .target(
      name: "CBFoundationTests",
      destinations: [.iPhone],
      product: .unitTests,
      bundleId: "\(Project.bundleId).CBFoundationTests",
      deploymentTargets: .iOS("17.0"),
      sources: ["Tests/**"],
      dependencies: [.target(name: "CBFoundation")]
    ),
  ]
)
