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
  func test_openURL_navigateToFeedbackForm() async {
    let store = makeSUT()
    arrange(store, toAssert: .feedbackFormUrl)
    arrange(store, toAssert: .clickSettingsPgFeedbackFormBtn(parameters: [:]))
    await store.send(.sendFeedbackButtonTapped)
  }
  
  func test_openURL_navigateToAuthorProfile() async {
    let store = makeSUT()
    arrange(store, toAssert: .authorProfileUrl)
    arrange(store, toAssert: .clickSettingsPgAuthorProfileBtn(parameters: [:]))
    await store.send(.authorProfileButtonTapped)
  }
}

extension UserSettingsFeatureTests {
  func makeSUT() -> TestStoreOf<SettingsFeature> {
    TestStore(
      initialState: SettingsFeature.State(),
      reducer: { SettingsFeature() }
    ) {
      $0.firebaseTracker = FirebaseTracker(logEvent: { _ in })
    }
  }
  
  func arrange(
    _ store: TestStoreOf<SettingsFeature>,
    toAssert destinationUrl: URL
  ) {
    store.dependencies.openURL = OpenURLEffect(
      handler: { url in
        XCTAssertEqual(url, destinationUrl)
        return true
      }
    )
  }
  
  func arrange(
    _ store: TestStoreOf<SettingsFeature>,
    toAssert event: FirebaseEvent
  ) {
    store.dependencies.firebaseTracker = FirebaseTracker(
      logEvent: { trackingEvent in
        XCTAssertEqual(trackingEvent, event)
      }
    )
  }
}
