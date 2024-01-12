//
//  DebugModeManager.swift
//
//
//  Created by Yi-Chin Hsu on 2024/1/12.
//

import Dependencies
import FirebaseRemoteConfig
import Foundation

struct DebugModeManager {
  var isFullAccess: (String) -> Bool
  var setAccess: (String) -> Void
}

extension DebugModeManager: DependencyKey {
  static var liveValue: DebugModeManager = DebugModeManager { key in
    UserDefaults.standard.bool(forKey: key)
  } setAccess: { activationKey in
    let remoteConfig = RemoteConfig.remoteConfig()
    remoteConfig.fetch { status, _ in
      if status == .success {
        remoteConfig.activate { _, _ in
          if let value = remoteConfig.configValue(forKey: "admin_full_access").stringValue, value == activationKey {
            UserDefaults.standard.setValue(true, forKey: "admin_full_access")
          }
        }
      }
    }
  }
}

extension DebugModeManager: TestDependencyKey {
  static var testValue: DebugModeManager = DebugModeManager { _ in
    unimplemented("DebugModeManager_isFullAccess")
  } setAccess: { _ in
    unimplemented("DebugModeManager_setAccess")
  }
}

extension DependencyValues {
  var debugModeManager: DebugModeManager {
    get { self[DebugModeManager.self] }
    set { self[DebugModeManager.self] = newValue }
  }
}
