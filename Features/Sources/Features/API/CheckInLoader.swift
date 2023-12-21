//
//  CheckInLoader.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/15.
//

import FirebaseFirestore

protocol CheckInLoader {
  func load() async throws -> [String]
}

class RemoteCheckInLoader: CheckInLoader {
  private let database = Firestore.firestore()
  let collectionPath: String

  init(collectionPath: String) {
    self.collectionPath = collectionPath
  }

  func load() async throws -> [String] {
    do {
      let result = try await database
        .collection(collectionPath)
        .getDocuments()
        .documents
        .compactMap { try $0.data(as: Question.self) }
        .map { $0.question }

      return result

    } catch {
      throw error
    }
  }
}
