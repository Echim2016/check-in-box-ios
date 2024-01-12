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
  func test_openURL_presentFeedbackForm() async {
    let store = makeSUT()
    store.arrangeTracker(for: .clickSettingsPgFeedbackFormBtn(parameters: [:]))
    await store.send(.sendFeedbackButtonTapped) {
      $0.presentInAppWebViewPage = InAppWebFeature.State(url: .feedbackFormUrl)
    }
  }

  func test_openURL_navigateToAuthorProfile() async {
    let store = makeSUT()
    store.arrangeOpenUrl(of: .authorProfileUrl)
    store.arrangeTracker(for: .clickSettingsPgAuthorProfileBtn(parameters: [:]))
    await store.send(.authorProfileButtonTapped)
  }

  func test_openURL_presentSubmitQuestionsForm() async {
    let store = makeSUT()
    store.arrangeTracker(for: .clickSettingsPgSubmitQuestionsBtn(parameters: [:]))
    await store.send(.submitQuestionsButtonTapped) {
      $0.presentInAppWebViewPage = InAppWebFeature.State(url: .submitQuestionsUrl)
    }
  }

  func test_shareButton_trackEventWhenTapped() async {
    let store = makeSUT()
    store.arrangeTracker(for: .clickSettingsPgShareBtn(parameters: [:]))
    XCTAssertEqual(store.state.shareLinkUrl, .shareLinkUrl)
    await store.send(.shareButtonTapped)
  }

  func test_settingPage_trackViewEvent() async {
    let store = makeSUT()
    store.arrangeTracker(for: .viewSettingsPg(parameters: [:]))
    await store.send(.trackViewSettingsPageEvent)
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
}
