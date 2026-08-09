//
//  CheckInBoxApp.swift
//  check-in-box-ios
//
//  Created by Yi-Chin Hsu on 2023/12/13.
//

import ComposableArchitecture
import FirebaseServiceLive
import Home
import SwiftUI

@main
struct CheckInBoxApp: App {
  @Dependency(\.firebaseTracker) var firebaseTracker
  private let store = Store(
    initialState: HomeFeature.State()
  ) {
    HomeFeature()
  }

  var body: some Scene {
    WindowGroup {
      HomeView(store: store)
    }
  }

  init() {
    firebaseTracker.configure()
  }
}
