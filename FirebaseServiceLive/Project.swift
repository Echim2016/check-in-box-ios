import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "FirebaseServiceLive",
  targets: [
    .target(
      name: "FirebaseServiceLive",
      destinations: [.iPhone, .iPad, .mac],
      product: .framework,
      bundleId: "\(Project.bundleId).FirebaseServiceLive",
      deploymentTargets: .iOS(Project.minimumDeploymentVersion),
      sources: ["Sources/**"],
      resources: nil,
      dependencies: [
        .composableArchitecture,
        .cbFoundation,
        .firebaseService,
        .firebaseAnalytics,
        .firebaseFirestore,
        .firebaseRemoteConfig,
      ],
      settings: .settings(
        base: [
          "OTHER_LDFLAGS": ["$(inherited) -ObjC"],
        ]
      )
    ),
    .target(
      name: "FirebaseServiceLiveTests",
      destinations: [.iPhone],
      product: .unitTests,
      bundleId: "\(Project.bundleId).FirebaseServiceLiveTests",
      deploymentTargets: .iOS("17.0"),
      sources: ["Tests/**"],
      dependencies: [.target(name: "FirebaseServiceLive")]
    ),
  ]
)
