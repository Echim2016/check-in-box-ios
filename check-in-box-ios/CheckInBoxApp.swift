//
//  CheckInBoxApp.swift
//  check-in-box-ios
//
//  Created by Yi-Chin Hsu on 2023/12/13.
//

import ComposableArchitecture
import Features
import SwiftUI

@main
struct CheckInBoxApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(
          initialState: AppFeature.State()
        ) {
          AppFeature()
        }
      )
    }
  }
}
