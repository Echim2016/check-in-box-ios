//
//  CheckInLoader.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/15.
//

import Dependencies
import FirebaseFirestore
import FirebaseRemoteConfig
import IdentifiedCollections

protocol CheckInLoader {
  var loadQuestions: (_ path: String) async throws -> IdentifiedArrayOf<Question> { get set }
  var loadTags: (_ path: String) async throws -> IdentifiedArrayOf<Tag> { get set }
  var loadThemeBoxes: (_ path: String, _ isFullAccess: Bool) async throws -> IdentifiedArrayOf<ThemeBox> { get set }
}

struct FirebaseCheckInLoader: CheckInLoader {
  var loadQuestions: (_ path: String) async throws -> IdentifiedArrayOf<Question>
  var loadTags: (_ path: String) async throws -> IdentifiedArrayOf<Tag>
  var loadThemeBoxes: (_ path: String, _ isFullAccess: Bool) async throws -> IdentifiedArrayOf<ThemeBox>

  static func loadFromRemote(path: String) async throws -> [QueryDocumentSnapshot] {
    let result = try await Firestore
      .firestore()
      .collection(path)
      .getDocuments()
      .documents

    return result
  }
}

extension FirebaseCheckInLoader: DependencyKey {
  static var liveValue = FirebaseCheckInLoader(
    loadQuestions: { path in
      let result = try await loadFromRemote(path: path)
        .compactMap { try $0.data(as: Question.self) }
        .filter { $0.isHidden == false }

      return IdentifiedArray(uniqueElements: result)
    },
    loadTags: { path in
      let result = try await loadFromRemote(path: path)
        .compactMap { try $0.data(as: Tag.self) }
        .filter { $0.isHidden == false }
        .sorted { $0.order < $1.order }

      return IdentifiedArray(uniqueElements: result)
    },
    loadThemeBoxes: { path, isFullAccess in
      let result = try await loadFromRemote(path: path)
        .compactMap { try $0.data(as: ThemeBox.self) }
        .filter { $0.isHidden == false || isFullAccess }
        .sorted { $0.order < $1.order }
      
      return IdentifiedArray(uniqueElements: result)
    }
  )
}

extension FirebaseCheckInLoader: TestDependencyKey {
  static var testValue = FirebaseCheckInLoader(
    loadQuestions: { _ in
      unimplemented("FirebaseCheckInLoader_loadQuestions", placeholder: [])
    },
    loadTags: { _ in
      unimplemented("FirebaseCheckInLoader_loadTags", placeholder: [])
    },
    loadThemeBoxes: { _, _ in
      unimplemented("FirebaseCheckInLoader_loadThemeBoxes", placeholder: [])
    }
  )
}

extension DependencyValues {
  var firebaseCheckInLoader: FirebaseCheckInLoader {
    get { self[FirebaseCheckInLoader.self] }
    set { self[FirebaseCheckInLoader.self] = newValue }
  }
}
