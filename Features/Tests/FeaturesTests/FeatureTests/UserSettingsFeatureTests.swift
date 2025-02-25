//
//  UserSettingsFeatureTests.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/21.
//

import ComposableArchitecture
@testable import Features
import XCTest

@MainActor
final class UserSettingsFeatureTests: XCTestCase {
  func test_openURL_presentAndCloseFeedbackForm() async {
    let store = makeSUT()
    store.arrangeTracker(for: .clickSettingsPgFeedbackFormBtn(parameters: [:]))
    await store.send(.sendFeedbackButtonTapped) {
      $0.presentInAppWebViewPage = InAppWebFeature.State(url: .feedbackFormUrl)
    }
    await store.send(.presentInAppWebViewPage(.presented(.closeButtonTapped))) {
      $0.presentInAppWebViewPage = nil
    }
  }

  func test_openURL_navigateToAuthorProfile() async {
    let store = makeSUT()
    store.arrangeOpenUrl(of: .authorProfileUrl)
    store.arrangeTracker(for: .clickSettingsPgAuthorProfileBtn(parameters: [:]))
    await store.send(.authorProfileButtonTapped)
  }

  func test_openURL_presentAndCloseSubmitQuestionsForm() async {
    let store = makeSUT()
    store.arrangeTracker(for: .clickSettingsPgSubmitQuestionsBtn(parameters: [:]))
    await store.send(.submitQuestionsButtonTapped) {
      $0.presentInAppWebViewPage = InAppWebFeature.State(url: .submitQuestionsUrl)
    }
    await store.send(.presentInAppWebViewPage(.presented(.closeButtonTapped))) {
      $0.presentInAppWebViewPage = nil
    }
  }

  func test_shareButton_trackEventWhenTapped() async {
    let store = makeSUT()
    store.arrangeTracker(for: .clickSettingsPgShareBtn(parameters: [:]))
    XCTAssertEqual(store.state.shareLinkUrl, .shareLinkUrl)
    await store.send(.shareButtonTapped)
  }
  
  func test_appReviewButton_trackEventWhenTapped() async {
    let store = makeSUT()
    store.arrangeOpenUrl(of: .requestReviewUrl)
    store.arrangeTracker(for: .clickSettingsPgSubmitAppReviewBtn(parameters: [:]))
    await store.send(.submitAppReviewButtonTapped)
  }

  func test_debugModeButton_presentDebugModeInoutBoxPage() async {
    let store = makeSUT()
    await store.send(.debugModeButtonTapped) {
      $0.presentDebugModeInputBoxPage = InputBoxFeature.State()
    }
  }
  
  func test_debugModeButton_enabled() async {
    let store = makeSUT()
    await store.send(.debugModeButtonEnabled) {
      $0.debugModeButtonEnabled = true
    }
  }

  func test_settingPage_trackViewEvent() async {
    let store = makeSUT()
    store.arrangeTracker(for: .viewSettingsPg(parameters: [:]))
    await store.send(.trackViewSettingsPageEvent)
  }
}

// MARK: - Tests for debug mode input box page

extension UserSettingsFeatureTests {
  func test_debugModeInputBoxPage_validActivationKeySubmitted() async {
    let activationKey = "valid_key"
    let store = makeSUT(
      state: SettingsFeature.State(
        presentDebugModeInputBoxPage: InputBoxFeature.State(
          activationKey: activationKey
        )
      )
    )
    arrangeDebugModeManagerOf(store, activationKey: activationKey)
    store.arrangeTracker(for: nil)

    await store.send(.presentDebugModeInputBoxPage(.presented(.activateButtonTapped)))
    await store.receive(.presentDebugModeInputBoxPage(.presented(.activationKeySubmitted(activationKey)))) { state in
      state.presentDebugModeInputBoxPage = nil
    }
  }

  func test_debugModeInputBoxPage_emptyActivationKeySubmitted() async {
    let activationKey = ""
    let store = makeSUT(
      state: SettingsFeature.State(
        presentDebugModeInputBoxPage: InputBoxFeature.State(
          activationKey: activationKey
        )
      )
    )
    arrangeDebugModeManagerOf(store, activationKey: activationKey)
    store.arrangeTracker(for: nil)

    await store.send(.presentDebugModeInputBoxPage(.presented(.activateButtonTapped)))
  }

  func test_debugModeInputBoxPage_keyChanged() async {
    let activationKey = ""
    let store = makeSUT(
      state: SettingsFeature.State(
        presentDebugModeInputBoxPage: InputBoxFeature.State(
          activationKey: activationKey
        )
      )
    )
    arrangeDebugModeManagerOf(store, activationKey: activationKey)
    store.arrangeTracker(for: nil)

    let modifiedKey = "k"
    await store.send(.presentDebugModeInputBoxPage(.presented(.keyChanged(modifiedKey)))) {
      $0.presentDebugModeInputBoxPage = InputBoxFeature.State(activationKey: modifiedKey)
    }
  }
}

extension UserSettingsFeatureTests {
  func makeSUT(state: SettingsFeature.State = SettingsFeature.State()) -> TestStoreOf<SettingsFeature> {
    TestStore(
      initialState: state,
      reducer: { SettingsFeature() }
    ) {
      $0.firebaseTracker = FirebaseTracker(
        logEvent: { event in
          XCTFail("\(event) is not handled")
        }
      )
      $0.openURL = OpenURLEffect(
        handler: { url in
          XCTFail("\(url) is not handled")
          return false
        }
      )
    }
  }

  func arrangeDebugModeManagerOf(
    _ store: TestStoreOf<SettingsFeature>,
    activationKey: String
  ) {
    store.dependencies.debugModeManager = DebugModeManager(
      isFullAccess: { key in
        XCTAssertEqual(activationKey, key)
        return true
      },
      setAccess: { key in
        XCTAssertEqual(activationKey, key)
      }
    )
  }
}
