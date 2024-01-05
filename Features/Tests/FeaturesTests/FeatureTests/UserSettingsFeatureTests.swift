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

  func test_shareButton_trackEventWhenTapped() async {
    let store = makeSUT()
    arrange(store, toAssert: .clickSettingsPgShareBtn(parameters: [:]))
    XCTAssertEqual(store.state.shareLinkUrl, .shareLinkUrl)
    await store.send(.shareButtonTapped)
  }

  func test_redeemGiftCardButton_presentGiftCardInoutBoxPage() async {
    let store = makeSUT()
    arrange(store, toAssert: .clickSettingsPgGiftCardBtn(parameters: [:]))
    await store.send(.redeemGiftCardButtonTapped) {
      $0.presentGiftCardInputBoxPage = InputBoxFeature.State()
    }
  }
}

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
    arrange(store, toAssert: activationKey)

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
    arrange(store, toAssert: activationKey)

    await store.send(.presentGiftCardInputBoxPage(.presented(.activateButtonTapped)))
  }
}

extension UserSettingsFeatureTests {
  func makeSUT(state: SettingsFeature.State = SettingsFeature.State()) -> TestStoreOf<SettingsFeature> {
    TestStore(
      initialState: state,
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
  
  func arrange(
    _ store: TestStoreOf<SettingsFeature>,
    toAssert activationKey: String
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
