//
//  HelperTests.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/19.
//

import ComposableArchitecture
import Foundation
@testable import Home
import Testing

struct CycleIteratorTests {
  @Test
  func test_cycleIterator_equatable() {
    let sut1 = CycleIterator(base: ["sut"], index: 0)
    let sut2 = CycleIterator(base: ["sut"], index: 1)

    #expect(sut1 != sut2)
  }

  @Test
  func test_cycleIterator_currentItem() {
    let item1 = "item1"
    let item2 = "item2"
    let sut = CycleIterator(base: [item1, item2], index: 1)

    #expect(sut.current() == item2)
  }

  @Test
  func test_cycleIterator_currentItemIsNilWhenBaseIsEmpty() {
    let base: [String] = []
    let sut = CycleIterator(base: base)

    #expect(sut.current() == nil)
  }

  @Test
  func test_cycleIterator_nextIndexEqualToZeroWhenBaseContainsOneItem() {
    let sut = CycleIterator(base: ["item1"], index: 0)
    sut.next()

    #expect(sut.index == 0)
    #expect(sut.base.count - 1 >= sut.index)
  }

  @Test
  func test_cycleIterator_backIndexEqualToZeroWhenBaseContainsOneItem() {
    let sut = CycleIterator(base: ["item1"], index: 0)
    sut.back()

    #expect(sut.index == 0)
    #expect(sut.base.count - 1 >= sut.index)
  }

  @Test
  func test_cycleIterator_nextIndexIncreasedByOneWhenBaseContainsMultipleItems() {
    let sut = CycleIterator(base: ["item1", "item2"], index: 0)
    sut.next()

    #expect(sut.index == 1)
    #expect(sut.base.count - 1 >= sut.index)
  }

  @Test
  func test_cycleIterator_backIndexDecreasedByOneWhenBaseContainsMultipleItems() {
    let sut = CycleIterator(base: ["item1", "item2"], index: 1)
    sut.back()

    #expect(sut.index == 0)
    #expect(sut.base.count - 1 >= sut.index)
  }

  @Test
  func test_cycleIterator_nextIndexWhenIndexOutOfRange() {
    let sut = CycleIterator(base: ["item1", "item2"], index: 1)
    sut.next()

    #expect(sut.index == 0)
    #expect(sut.base.count - 1 >= sut.index)
  }

  @Test
  func test_cycleIterator_backIndexWhenIndexOutOfRange() {
    let sut = CycleIterator(base: ["item1", "item2"], index: 0)
    sut.back()

    #expect(sut.index == 1)
    #expect(sut.base.count - 1 >= sut.index)
  }

  @Test
  func test_raceCondition_performNextFromMultipleThreadsConcurrently() {
    let mockItems = ["item1", "item2", "item3", "item4", "item5", "item6", "item7", "item8", "item9", "item10"]
    let sut = CycleIterator(base: mockItems, index: 0)

    DispatchQueue.concurrentPerform(iterations: mockItems.count - 1) { _ in
      sut.next()
    }

    Thread.sleep(forTimeInterval: 0.05)
    #expect(sut.index == mockItems.count - 1)
  }
}
