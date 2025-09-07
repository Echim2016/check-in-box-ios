//
//  DebugModeManager.swift
//  FirebaseService
//
//  Created by Yi-Chin Hsu on 2025/9/6.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct DebugModeManager {
  public var isFullAccess: (String) -> Bool = { _ in false }
  public var setAccess: (String) -> Void
}

extension DebugModeManager: TestDependencyKey {
  public static var testValue: DebugModeManager = Self()
}

extension DependencyValues {
  public var debugModeManager: DebugModeManager {
    get { self[DebugModeManager.self] }
    set { self[DebugModeManager.self] = newValue }
  }
}
