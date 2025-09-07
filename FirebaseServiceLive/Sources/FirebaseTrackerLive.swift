//
//  FirebaseTracker.swift
//
//
//  Created by Yi-Chin Hsu on 2025/9/6.
//

import Dependencies
import FirebaseAnalytics
import FirebaseCore
import FirebaseService

extension FirebaseTracker: Dependencies.DependencyKey {
 
  public static var liveValue = FirebaseTracker(
    configure: {
      Analytics.setAnalyticsCollectionEnabled(true)
      FirebaseApp.configure()
    },
    logEvent: { event in
      Analytics.logEvent(event.name, parameters: event.parameters)
    }
  )
}
