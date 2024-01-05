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
    assert(store, open: .feedbackFormUrl)
    await store.send(.sendFeedbackButtonTapped)
  }
  
  func test_openURL_navigateToAuthorProfile() async {
    let store = makeSUT()
    assert(store, open: .authorProfileUrl)
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
  
  func assert(
    _ store: TestStoreOf<SettingsFeature>,
    open destinationUrl: URL
  ) {
    store.dependencies.openURL = OpenURLEffect(
      handler: { url in
        XCTAssertEqual(url, destinationUrl)
        return true
      }
    )
  }
}
