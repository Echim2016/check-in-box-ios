//
//  CheckInLoader.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/15.
//

import Dependencies
import FirebaseFirestore

protocol CheckInLoader {
  var load: (_ path: String) async -> [String] { get set }
}

struct FirebaseCheckInLoader: CheckInLoader {
  var load: (_ path: String) async -> [String]
}

extension FirebaseCheckInLoader: DependencyKey {
  static var liveValue = FirebaseCheckInLoader { path in
    do {
      let result = try await Firestore
        .firestore()
        .collection(path)
        .getDocuments()
        .documents
        .compactMap { try $0.data(as: Question.self) }
        .map { $0.question }

      return result

    } catch {
      return []
    }
  }
}

extension FirebaseCheckInLoader: TestDependencyKey {
  static var testValue = FirebaseCheckInLoader(load: unimplemented("FirebaseCheckInLoader"))
}

extension DependencyValues {
  var firebaseCheckInLoader: FirebaseCheckInLoader {
    get { self[FirebaseCheckInLoader.self] }
    set { self[FirebaseCheckInLoader.self] = newValue }
  }
}
