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
}
