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
    let store = TestStore(
      initialState: ModeListFeature.State(featureCards: FeatureCard.default)
    ) {
      ModeListFeature()
    }

    await store.send(.settingsButtonTapped) {
      $0.presentSettingsPage = SettingsFeature.State()
    }
  }

  func test_settingsSheet_dismissedWhenDoneButtonTapped() async {
    let store = TestStore(
      initialState: ModeListFeature.State(
        presentSettingsPage: SettingsFeature.State(),
        featureCards: FeatureCard.default
      )
    ) {
      ModeListFeature()
    }

    await store.send(.settingsSheetDoneButtonTapped) {
      $0.presentSettingsPage = nil
    }
  }

  func test_questions_reloadWhenPullToRefresh() async {
    let questions = IdentifiedArray(uniqueElements: getMockMultipleQuestions())
    let tags = IdentifiedArray(uniqueElements: getMockTags())
    let store = TestStore(
      initialState: AppFeature.State(modeList: ModeListFeature.State(featureCards: FeatureCard.default)),
      reducer: { AppFeature() }
    ) {
      $0.firebaseCheckInLoader = FirebaseCheckInLoader(
        loadQuestions: { _ in
          questions
        },
        loadTags: { _ in
          tags
        }
      )
    }

    await store.send(.loadFromRemote)
    await store.receive(.receivedQuestions(tags, questions)) {
      $0.modeList.tags = tags
      $0.modeList.questions = questions
    }

    let updatedQuestions: IdentifiedArrayOf<Question> = []
    let updatedTags: IdentifiedArrayOf<Tag> = []
    store.dependencies.firebaseCheckInLoader = FirebaseCheckInLoader(
      loadQuestions: { _ in
        updatedQuestions
      },
      loadTags: { _ in
        updatedTags
      }
    )

    await store.send(.modeList(.pullToRefreshTriggered))
    await store.receive(.loadFromRemote)
    await store.receive(.receivedQuestions(updatedTags, updatedQuestions)) {
      $0.modeList.tags = updatedTags
      $0.modeList.questions = updatedQuestions
    }
  }
}
