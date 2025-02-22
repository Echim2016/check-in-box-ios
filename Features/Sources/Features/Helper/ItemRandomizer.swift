//
//  ItemRandomizer.swift
//
//
//  Created by Yi-Chin Hsu on 2024/2/1.
//

import Dependencies

struct ItemRandomizer {
  var shuffleHandler: ([Any]) -> [Any]

  func shuffling<T>(_ elements: [T]) -> [T] {
    (shuffleHandler(elements) as? [T]) ?? []
  }
}

extension DependencyValues {
  var itemRandomizer: ItemRandomizer {
    get { self[ItemRandomizerKey.self] }
    set { self[ItemRandomizerKey.self] = newValue }
  }

  struct ItemRandomizerKey: DependencyKey, TestDependencyKey {
    static let liveValue: ItemRandomizer = .init(
      shuffleHandler: { items in
        items.shuffled()
      }
    )

    static let testValue: ItemRandomizer = .init(
      shuffleHandler: { _ in
        unimplemented("ItemRandomizer_shuffled", placeholder: [])
      }
    )
  }
}
