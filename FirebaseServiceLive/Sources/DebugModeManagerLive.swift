//
//  DebugModeManagerLive.swift
//  FirebaseServiceLive
//
//  Created by Yi-Chin Hsu on 2025/9/6.
//

import CBFoundation
import Dependencies
import FirebaseRemoteConfig
import FirebaseService
import Foundation
import Sharing

extension DebugModeManager: DependencyKey {
  public static var liveValue = DebugModeManager(
    isFullAccess: {
      @Shared(.adminFullAccess) var isFullAccess
      return isFullAccess
    },
    setAccess: { activationKey in
      let remoteConfig = RemoteConfig.remoteConfig()
      remoteConfig.fetch { status, _ in
        if status == .success {
          remoteConfig.activate { _, _ in
            if remoteConfig.configValue(forKey: AppStorageKeys.adminFullAccess).stringValue == activationKey {
              @Shared(.adminFullAccess) var isFullAccess
              $isFullAccess.withLock { $0 = true }
            }
          }
        }
      }
    }
  )
}
