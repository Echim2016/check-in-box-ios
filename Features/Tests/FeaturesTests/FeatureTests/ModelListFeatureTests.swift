//
//  ModelListFeatureTests.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/21.
//

import ComposableArchitecture
@testable import Features
import XCTest

@MainActor
final class ModelListFeatureTests: XCTestCase {
  func test_settingsSheet_presentedWhenSettingButtonTapped() async {
    let store = makeSUT()

    await store.send(.settingsButtonTapped) {
      $0.presentSettingsPage = SettingsFeature.State()
    }
  }

  func test_settingsSheet_dismissedWhenDoneButtonTapped() async {
    let store = makeSUT(isSettingsPagePresented: true)
    store.arrangeTracker(for: .viewModeListPg(parameters: [:]))

    await store.send(.settingsSheetDoneButtonTapped) {
      $0.presentSettingsPage = nil
    }
  }
  
  func test_settingsSheet_dismissed() async {
    let store = makeSUT(isSettingsPagePresented: true)
    store.arrangeTracker(for: .viewModeListPg(parameters: [:]))

    await store.send(.presentSettingsPage(.dismiss)) {
      $0.presentSettingsPage = nil
    }
  }

  func test_questions_reloadWhenPullToRefresh() async {
    let questions = IdentifiedArray(uniqueElements: getMockMultipleQuestions())
    let tags = IdentifiedArray(uniqueElements: getMockTags())
    let themeBoxes = IdentifiedArray(uniqueElements: getMockThemeBoxes())

    let store = TestStore(
      initialState: AppFeature.State(modeList: ModeListFeature.State()),
      reducer: { AppFeature() }
    ) {
      $0.firebaseCheckInLoader = FirebaseCheckInLoader(
        loadQuestions: { _ in
          questions
        },
        loadTags: { _ in
          tags
        },
        loadThemeBoxes: { _, _ in
          themeBoxes
        }
      )
      $0.giftCardAccessManager = GiftCardAccessManager(
        isFullAccess: { _ in
          true
        },
        setAccess: { _ in }
      )
    }

    await store.send(.loadFromRemote)
    await store.receive(.receivedQuestions(themeBoxes, tags, questions)) {
      $0.modeList.themeBoxes = themeBoxes
      $0.modeList.tags = tags
      $0.modeList.questions = questions
    }

    let updatedQuestions: IdentifiedArrayOf<Question> = []
    let updatedTags: IdentifiedArrayOf<Tag> = []
    let updatedThemeBoxes: IdentifiedArrayOf<ThemeBox> = []
    store.dependencies.firebaseCheckInLoader = FirebaseCheckInLoader(
      loadQuestions: { _ in
        updatedQuestions
      },
      loadTags: { _ in
        updatedTags
      },
      loadThemeBoxes: { _, _ in
        updatedThemeBoxes
      }
    )

    await store.send(.modeList(.pullToRefreshTriggered))
    await store.receive(.loadFromRemote)
    await store.receive(.receivedQuestions(updatedThemeBoxes, updatedTags, updatedQuestions)) {
      $0.modeList.themeBoxes = updatedThemeBoxes
      $0.modeList.tags = updatedTags
      $0.modeList.questions = updatedQuestions
    }
  }
  
  func test_modeList_trackViewEvent() async {
    let store = TestStore(
      initialState: ModeListFeature.State(),
      reducer: { ModeListFeature() }
    ) {
      $0.firebaseTracker = FirebaseTracker(
        logEvent: { event in
          XCTAssertEqual(event, .viewModeListPg(parameters: [:]))
        }
      )
    }

    await store.send(.trackViewModeListEvent)
  }
  
  func makeSUT(isSettingsPagePresented: Bool = false) -> TestStoreOf<ModeListFeature> {
    TestStore(
      initialState: ModeListFeature.State(
        presentSettingsPage: isSettingsPagePresented ? SettingsFeature.State() : nil
      ),
      reducer: { ModeListFeature() }
    ) {
      $0.firebaseTracker = FirebaseTracker(
        logEvent: { event in
          XCTFail("\(event) is not handled")
        }
      )
    }
  }
}
