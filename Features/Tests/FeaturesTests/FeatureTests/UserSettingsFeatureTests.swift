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
    arrangeOpenUrlOf(store, destinationUrl: .feedbackFormUrl)
    arrangeTrackerOf(store, event: .clickSettingsPgFeedbackFormBtn(parameters: [:]))
    await store.send(.sendFeedbackButtonTapped)
  }

  func test_openURL_navigateToAuthorProfile() async {
    let store = makeSUT()
    arrangeOpenUrlOf(store, destinationUrl: .authorProfileUrl)
    arrangeTrackerOf(store, event: .clickSettingsPgAuthorProfileBtn(parameters: [:]))
    await store.send(.authorProfileButtonTapped)
  }

  func test_shareButton_trackEventWhenTapped() async {
    let store = makeSUT()
    arrangeTrackerOf(store, event: .clickSettingsPgShareBtn(parameters: [:]))
    XCTAssertEqual(store.state.shareLinkUrl, .shareLinkUrl)
    await store.send(.shareButtonTapped)
  }

  func test_redeemGiftCardButton_presentGiftCardInoutBoxPage() async {
    let store = makeSUT()
    arrangeTrackerOf(store, event: .clickSettingsPgGiftCardBtn(parameters: [:]))
    await store.send(.redeemGiftCardButtonTapped) {
      $0.presentGiftCardInputBoxPage = InputBoxFeature.State()
    }
  }

  func test_settingPage_trackViewEvent() async {
    let store = makeSUT()
    arrangeTrackerOf(store, event: .viewSettingsPg(parameters: [:]))
    await store.send(.trackViewSettingsPageEvent)
  }
}

// MARK: - Tests for gift card input box page

extension UserSettingsFeatureTests {
  func test_giftCardInputBoxPage_validActivationKeySubmitted() async {
    let activationKey = "valid_key"
    let store = makeSUT(
      state: SettingsFeature.State(
        presentGiftCardInputBoxPage: InputBoxFeature.State(
          activationKey: activationKey
        )
      )
    )
    arrangeGiftCardAccessManagerOf(store, activationKey: activationKey)
    arrangeTrackerOf(store, event: nil)

    await store.send(.presentGiftCardInputBoxPage(.presented(.activateButtonTapped)))
    await store.receive(.presentGiftCardInputBoxPage(.presented(.activationKeySubmitted(activationKey)))) { state in
      state.presentGiftCardInputBoxPage = nil
      state.hapticFeedbackTrigger = true
    }
  }

  func test_giftCardInputBoxPage_emptyActivationKeySubmitted() async {
    let activationKey = ""
    let store = makeSUT(
      state: SettingsFeature.State(
        presentGiftCardInputBoxPage: InputBoxFeature.State(
          activationKey: activationKey
        )
      )
    )
    arrangeGiftCardAccessManagerOf(store, activationKey: activationKey)
    arrangeTrackerOf(store, event: nil)

    await store.send(.presentGiftCardInputBoxPage(.presented(.activateButtonTapped)))
  }

  func test_giftCardInputBoxPage_keyChanged() async {
    let activationKey = ""
    let store = makeSUT(
      state: SettingsFeature.State(
        presentGiftCardInputBoxPage: InputBoxFeature.State(
          activationKey: activationKey
        )
      )
    )
    arrangeGiftCardAccessManagerOf(store, activationKey: activationKey)
    arrangeTrackerOf(store, event: nil)

    let modifiedKey = "k"
    await store.send(.presentGiftCardInputBoxPage(.presented(.keyChanged(modifiedKey)))) {
      $0.presentGiftCardInputBoxPage = InputBoxFeature.State(activationKey: modifiedKey)
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
          XCTAssertNil(event, "\(event) is not handled")
        }
      )
    }
  }

  func arrangeOpenUrlOf(
    _ store: TestStoreOf<SettingsFeature>,
    destinationUrl: URL
  ) {
    store.dependencies.openURL = OpenURLEffect(
      handler: { url in
        XCTAssertEqual(url, destinationUrl)
        return true
      }
    )
  }

  func arrangeTrackerOf(
    _ store: TestStoreOf<SettingsFeature>,
    event: FirebaseEvent?
  ) {
    store.dependencies.firebaseTracker = FirebaseTracker(
      logEvent: { trackingEvent in
        if let event {
          XCTAssertEqual(trackingEvent, event)
        }
      }
    )
  }
  
  func arrangeGiftCardAccessManagerOf(
    _ store: TestStoreOf<SettingsFeature>,
    activationKey: String
  ) {
    store.dependencies.giftCardAccessManager = GiftCardAccessManager(
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
