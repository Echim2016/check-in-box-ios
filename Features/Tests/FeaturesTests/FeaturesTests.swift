import ComposableArchitecture
@testable import Features
import XCTest

@MainActor
final class AppFeaturesTests: XCTestCase {
  func test_path_navigateToClassicPage() async {
    let store = TestStore(
      initialState: AppFeature.State(modeList: ModeListFeature.State(featureCards: FeatureCard.default))
    ) {
      AppFeature()
    }

    await store.send(.path(.push(id: 0, state: .classic(ClassicCheckInFeature.State())))) {
      $0.path[id: 0] = .classic(ClassicCheckInFeature.State())
    }
  }

  func test_loadQuestions_fromRemoteLoader() async {
    let mockQuestions = getMockMultipleQuestions()
    let store = TestStore(
      initialState: AppFeature.State(modeList: ModeListFeature.State(featureCards: FeatureCard.default)),
      reducer: { AppFeature() }
    ) {
      $0.firebaseCheckInLoader = FirebaseCheckInLoader(
        load: { collectionPath in
          XCTAssertEqual(collectionPath, "Questions")
          return mockQuestions
        }
      )
    }

    await store.send(.loadFromRemote)
    await store.receive(.receivedQuestions(mockQuestions)) {
      $0.modeList.questions = mockQuestions
    }
  }
}
