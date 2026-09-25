//
//  TestStore+Extensions.swift
//
//
//  Created by Yi-Chin Hsu on 2024/1/9.
//

import ComposableArchitecture
@testable import FirebaseService
import Foundation
@testable import Home
import Testing

extension TestStore {
  func arrangeTracker(for events: FirebaseEvent?...) {
    dependencies.firebaseTracker = FirebaseTracker(
      configure: {},
      logEvent: { trackingEvent in
        if !events.contains(trackingEvent) {
          Issue.record("Unhandled tracking event: \(trackingEvent). Expected: \(events)")
        }
      }
    )
  }

  func arrangeOpenUrl(of destinationUrl: URL) {
    dependencies.openURL = OpenURLEffect(
      handler: { url in
        if url != destinationUrl {
          Issue.record("Unhandled URL: \(url). Expected: \(destinationUrl)")
        }
        return true
      }
    )
  }
}
