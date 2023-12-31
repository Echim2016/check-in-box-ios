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
    let store = TestStore(
      initialState: SettingsFeature.State(),
      reducer: { SettingsFeature() }
    ) {
      $0.openURL = OpenURLEffect(
        handler: { url in
          XCTAssertEqual(url, URL(string: "https://forms.gle/Vr4MjtowWPxBxr5r9")!)
          return true
        }
      )
    }

    await store.send(.sendFeedbackButtonTapped)
  }
}
