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
  func arrangeTracker(for events: FirebaseEvent?...) {
    dependencies.firebaseTracker = FirebaseTracker(
      logEvent: { trackingEvent in
        XCTAssertTrue(events.contains(trackingEvent))
      }
    )
  }
  
  func arrangeOpenUrl(of destinationUrl: URL) {
    dependencies.openURL = OpenURLEffect(
      handler: { url in
        XCTAssertEqual(url, destinationUrl)
        return true
      }
    )
  }
}
