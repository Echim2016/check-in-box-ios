//
//  CycleIterator.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/19.
//

class CycleIterator<T: Equatable>: Equatable {
  var base: [T] = []
  var index: Int = 0

  init(base: [T]) {
    self.base = base
  }

  func next() -> T? {
    guard !base.isEmpty else {
      return nil
    }
    index = (index + 1) % base.count
    return base[index]
  }

  static func == (lhs: CycleIterator<T>, rhs: CycleIterator<T>) -> Bool {
    lhs.base == rhs.base
  }
}
