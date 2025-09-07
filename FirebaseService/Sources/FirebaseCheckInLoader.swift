//
//  FirebaseCheckInLoader.swift
//  FirebaseService
//
//  Created by Yi-Chin Hsu on 2025/9/6.
//

import CBFoundation
import Dependencies
import DependenciesMacros
import IdentifiedCollections

@DependencyClient
public struct FirebaseCheckInLoader {
  public var loadQuestions: (_ path: String) async throws -> IdentifiedArrayOf<Question>
  public var loadTags: (_ path: String) async throws -> IdentifiedArrayOf<Tag>
  public var loadThemeBoxes: (_ path: String, _ isFullAccess: Bool) async throws -> IdentifiedArrayOf<ThemeBox>
}

extension FirebaseCheckInLoader: TestDependencyKey {
  public static var testValue = Self()
}

extension DependencyValues {
  public var firebaseCheckInLoader: FirebaseCheckInLoader {
    get { self[FirebaseCheckInLoader.self] }
    set { self[FirebaseCheckInLoader.self] = newValue }
  }
}
