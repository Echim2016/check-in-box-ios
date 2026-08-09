//
//  CycleCollection.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/19.
//

public struct CycleCollection<T: Equatable>: Equatable {
  var base: [T] = []
  var index: Int = 0

  public init(base: [T], index: Int = 0) {
    self.base = base
    self.index = base.indices.contains(index) ? index : 0
  }

  var count: Int {
    base.count
  }

  func current() -> T? {
    guard base.indices.contains(index) else { return nil }
    return base[index]
  }

  @discardableResult
  mutating func next() -> T? {
    guard !base.isEmpty else { return nil }
    index = (index + 1) % base.count
    return current()
  }

  @discardableResult
  mutating func back() -> T? {
    guard !base.isEmpty else { return nil }
    index = index > 0 ? index - 1 : base.count - 1
    return current()
  }
}
