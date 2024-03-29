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
      initialState: AppFeature.State(modeList: ModeListFeature.State())
    ) {
      AppFeature()
    }
    let checkInState = ClassicCheckInFeature.State(tag: Tag(code: "Test"))
    
    await store.send(.modeList(.navigateToCheckInPage(checkInState))) {
      $0.path[id: 0] = .classic(checkInState)
    }
  }
  
  func test_path_pushToClassicPage() async {
    let store = TestStore(
      initialState: AppFeature.State(modeList: ModeListFeature.State())
    ) {
      AppFeature()
    }
    let checkInState = ClassicCheckInFeature.State(tag: Tag(code: "Test"))

    await store.send(.path(.push(id: 0, state: .classic(checkInState)))) {
      $0.path[id: 0] = .classic(checkInState)
    }
  }

  func test_loadQuestions_fromRemoteLoader() async {
    let mockQuestions = IdentifiedArray(uniqueElements: getMockMultipleQuestions())
    let mockTags = IdentifiedArray(uniqueElements: getMockTags())
    let mockThemeBoxes = IdentifiedArray(uniqueElements: getMockThemeBoxes())

    let store = TestStore(
      initialState: AppFeature.State(modeList: ModeListFeature.State()),
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
        },
        loadThemeBoxes: { collectionPath, isFullAccess in
          XCTAssertEqual(collectionPath, "Theme_Boxes")
          return IdentifiedArray(uniqueElements: mockThemeBoxes)
        }
      )
      $0.debugModeManager = DebugModeManager(
        isFullAccess: { _ in
          true
        },
        setAccess: { _ in }
      )
    }
    
    await store.send(.modeList(.pullToRefreshTriggered))
    await store.receive(.loadFromRemote)
    await store.receive(.receivedQuestions(mockThemeBoxes, mockTags, mockQuestions)) {
      $0.modeList.themeBoxes = mockThemeBoxes
      $0.modeList.tags = mockTags
      $0.modeList.questions = mockQuestions
    }
  }
}
