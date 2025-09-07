//
//  FirebaseCheckInLoaderLive.swift
//  FirebaseServiceLive
//
//  Created by Yi-Chin Hsu on 2025/9/6.
//

import CBFoundation
import Dependencies
import FirebaseService
import FirebaseFirestore
import IdentifiedCollections

struct FirebaseRemoteLoader {
  static func loadFromRemote(path: String) async throws -> [QueryDocumentSnapshot] {
    let result = try await Firestore
      .firestore()
      .collection(path)
      .getDocuments()
      .documents

    return result
  }
}

extension FirebaseCheckInLoader: Dependencies.DependencyKey {
  public static var liveValue = FirebaseCheckInLoader(
    loadQuestions: { path in
      let result = try await FirebaseRemoteLoader.loadFromRemote(path: path)
        .compactMap { try $0.data(as: Question.self) }
        .filter { $0.isHidden == false }

      return IdentifiedArray(uniqueElements: result)
    },
    loadTags: { path in
      let result = try await FirebaseRemoteLoader.loadFromRemote(path: path)
        .compactMap { try $0.data(as: Tag.self) }
        .filter { $0.isHidden == false }
        .sorted { $0.order < $1.order }

      return IdentifiedArray(uniqueElements: result)
    },
    loadThemeBoxes: { path, isFullAccess in
      let result = try await FirebaseRemoteLoader.loadFromRemote(path: path)
        .compactMap { try $0.data(as: ThemeBox.self) }
        .filter { $0.isHidden == false || isFullAccess }
        .sorted { $0.order < $1.order }
      
      return IdentifiedArray(uniqueElements: result)
    }
  )
}
