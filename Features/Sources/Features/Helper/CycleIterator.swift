//
//  CycleIterator.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/19.
//

class CycleIterator<T: Equatable>: Equatable {
  var base: [T] = []
  var index: Int = 0

  init(base: [T], index: Int = 0) {
    self.base = base
    self.index = index
  }

  func current() -> T? {
    if base.isEmpty {
      return nil
    } else {
      return base[index]
    }
  }

  @discardableResult
  func next() -> T? {
    guard !base.isEmpty else {
      return nil
    }
    if base.count > 1 {
      index = (index + 1) % base.count
    } else {
      index = 0
    }
    return base[index]
  }

  @discardableResult
  func back() -> T? {
    guard !base.isEmpty else {
      return nil
    }
    if index > 0 {
      index = (index - 1) % base.count
    } else {
      index = base.count - 1
    }
    return base[index]
  }

  static func == (lhs: CycleIterator<T>, rhs: CycleIterator<T>) -> Bool {
    lhs.base == rhs.base && lhs.index == rhs.index
  }
}
