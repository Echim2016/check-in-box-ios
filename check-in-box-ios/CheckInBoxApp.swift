//
//  CheckInBoxApp.swift
//  check-in-box-ios
//
//  Created by Yi-Chin Hsu on 2023/12/13.
//

import ComposableArchitecture
import Features
import FirebaseCore
import SwiftUI

@main
struct CheckInBoxApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(
          initialState: AppFeature.State(modeList: ModeListFeature.State(featureCards: FeatureCard.default))
        ) {
          AppFeature()
        }
      )
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
