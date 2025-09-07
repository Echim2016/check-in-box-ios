//
//  HelperTests.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/19.
//

import ComposableArchitecture
@testable import Home
import XCTest

@MainActor
final class CycleIteratorTests: XCTestCase {
  func test_cycleIterator_equatable() {
    let sut1 = CycleIterator(base: ["sut"], index: 0)
    let sut2 = CycleIterator(base: ["sut"], index: 1)

    XCTAssertNotEqual(sut1, sut2)
  }

  func test_cycleIterator_currentItem() {
    let item1 = "item1"
    let item2 = "item2"
    let sut = CycleIterator(base: [item1, item2], index: 1)

    XCTAssertEqual(sut.current(), item2)
  }

  func test_cycleIterator_currentItemIsNilWhenBaseIsEmpty() {
    let base: [String] = []
    let sut = CycleIterator(base: base)

    XCTAssertNil(sut.current())
  }

  func test_cycleIterator_nextIndexEqualToZeroWhenBaseContainsOneItem() {
    let sut = CycleIterator(base: ["item1"], index: 0)
    sut.next()

    XCTAssertEqual(sut.index, 0)
    XCTAssertGreaterThanOrEqual(sut.base.count - 1, sut.index)
  }

  func test_cycleIterator_backIndexEqualToZeroWhenBaseContainsOneItem() {
    let sut = CycleIterator(base: ["item1"], index: 0)
    sut.back()

    XCTAssertEqual(sut.index, 0)
    XCTAssertGreaterThanOrEqual(sut.base.count - 1, sut.index)
  }

  func test_cycleIterator_nextIndexIncreasedByOneWhenBaseContainsMultipleItems() {
    let sut = CycleIterator(base: ["item1", "item2"], index: 0)
    sut.next()

    XCTAssertEqual(sut.index, 1)
    XCTAssertGreaterThanOrEqual(sut.base.count - 1, sut.index)
  }

  func test_cycleIterator_backIndexDecreasedByOneWhenBaseContainsMultipleItems() {
    let sut = CycleIterator(base: ["item1", "item2"], index: 1)
    sut.back()

    XCTAssertEqual(sut.index, 0)
    XCTAssertGreaterThanOrEqual(sut.base.count - 1, sut.index)
  }

  func test_cycleIterator_nextIndexWhenIndexOutOfRange() {
    let sut = CycleIterator(base: ["item1", "item2"], index: 1)
    sut.next()

    XCTAssertEqual(sut.index, 0)
    XCTAssertGreaterThanOrEqual(sut.base.count - 1, sut.index)
  }

  func test_cycleIterator_backIndexWhenIndexOutOfRange() {
    let sut = CycleIterator(base: ["item1", "item2"], index: 0)
    sut.back()

    XCTAssertEqual(sut.index, 1)
    XCTAssertGreaterThanOrEqual(sut.base.count - 1, sut.index)
  }

  func test_raceCondition_performNextFromMultipleThreadsConcurrently() {
    let mockItems = ["item1", "item2", "item3", "item4", "item5", "item6", "item7", "item8", "item9", "item10"]
    let sut = CycleIterator(base: mockItems, index: 0)

    DispatchQueue.concurrentPerform(iterations: mockItems.count - 1) { _ in
      sut.next()
    }

    let exp = expectation(description: "Test after concurrent performing done")
    let result = XCTWaiter.wait(for: [exp], timeout: 0.05)
    if result == XCTWaiter.Result.timedOut {
      XCTAssertEqual(sut.index, mockItems.count - 1)
    }
  }
}
