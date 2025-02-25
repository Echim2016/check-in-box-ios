//
//  CheckInBoxApp.swift
//  check-in-box-ios
//
//  Created by Yi-Chin Hsu on 2023/12/13.
//

import ComposableArchitecture
import Features
import FirebaseAnalytics
import FirebaseCore
import SwiftUI

@main
struct CheckInBoxApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(
          initialState: AppFeature.State(
            modeList: ModeListFeature.State(
              presentInfoPage: UserDefaults.standard.bool(forKey: "info-intro-checked") ? nil : InfoSheetFeature.State()
            )
          )
        ) {
          AppFeature()
        }
      )
    }
  }

  init() {
    Analytics.setAnalyticsCollectionEnabled(true)
    FirebaseApp.configure()
  }
}
