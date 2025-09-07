//
//  DebugModeManagerLive.swift
//  FirebaseServiceLive
//
//  Created by Yi-Chin Hsu on 2025/9/6.
//

import Dependencies
import FirebaseRemoteConfig
import FirebaseService
import Foundation

extension DebugModeManager: DependencyKey {
  public static var liveValue = DebugModeManager { key in
    UserDefaults.standard.bool(forKey: key)
  } setAccess: { activationKey in
    let remoteConfig = RemoteConfig.remoteConfig()
    remoteConfig.fetch { status, _ in
      if status == .success {
        remoteConfig.activate { _, _ in
          if remoteConfig.configValue(forKey: "admin_full_access").stringValue == activationKey {
            UserDefaults.standard.setValue(true, forKey: "admin_full_access")
          }
        }
      }
    }
  }
}
