//
//  AppFeaturesTests.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/13.
//

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
    let mockQuestions = IdentifiedArray(uniqueElements: getMockMultipleQuestions())
    let mockTags = IdentifiedArray(uniqueElements: getMockTags())

    let store = TestStore(
      initialState: AppFeature.State(modeList: ModeListFeature.State(featureCards: FeatureCard.default)),
      reducer: { AppFeature() }
    ) {
      $0.firebaseCheckInLoader = FirebaseCheckInLoader(
        loadQuestions: { collectionPath in
          XCTAssertEqual(collectionPath, "Questions")
          return IdentifiedArray(uniqueElements: mockQuestions)
        },
        loadTags: { collectionPath in
          XCTAssertEqual(collectionPath, "Question_Tags")
          return IdentifiedArray(uniqueElements: mockTags)
        }
      )
    }

    await store.send(.loadFromRemote)
    await store.receive(.receivedQuestions(mockTags, mockQuestions)) {
      $0.modeList.tags = mockTags
      $0.modeList.questions = mockQuestions
    }
  }
}
