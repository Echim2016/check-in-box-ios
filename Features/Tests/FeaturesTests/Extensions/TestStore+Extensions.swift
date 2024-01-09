//
//  TestStore+Extensions.swift
//
//
//  Created by Yi-Chin Hsu on 2024/1/9.
//

import ComposableArchitecture
@testable import Features
import XCTest

extension TestStore {
  func arrangeTracker(for event: FirebaseEvent?) {
    dependencies.firebaseTracker = FirebaseTracker(
      logEvent: { trackingEvent in
        if let event {
          XCTAssertEqual(trackingEvent, event)
        }
      }
    )
  }
}
