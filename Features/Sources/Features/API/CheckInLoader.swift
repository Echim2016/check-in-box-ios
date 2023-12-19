//
//  CheckInLoader.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/15.
//

import Foundation

protocol CheckInLoader {
  func load() async throws -> [String]
}

class RemoteCheckInLoader: CheckInLoader {
  func load() async throws -> [String] {
    // TODO: Replace with firebase response
    await withCheckedContinuation { continuation in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        continuation.resume(
          with:
          .success(
            [
              "身上使用最久的東西是什麼？",
              "最喜歡的一部電影？",
              "今年最期待的一件事情？",
              "我不為人知的一個奇怪技能",
              "做過最像大人的事情",
              "今年最快樂的回憶",
              "最想再去一次的國家/城市",
            ]
          )
        )
      }
    }
  }
}
