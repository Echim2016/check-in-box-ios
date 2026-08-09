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

struct CycleCollectionTests {
  @Test
  func test_cycleCollection_equatable() {
    let sut1 = CycleCollection(base: ["sut"], index: 0)
    let sut2 = CycleCollection(base: ["sut"], index: 1)

    #expect(sut1 != sut2)
  }

  @Test
  func test_cycleCollection_currentItem() {
    let item1 = "item1"
    let item2 = "item2"
    let sut = CycleCollection(base: [item1, item2], index: 1)

    #expect(sut.current() == item2)
  }

  @Test
  func test_cycleCollection_currentItemIsNilWhenBaseIsEmpty() {
    let base: [String] = []
    let sut = CycleCollection(base: base)

    #expect(sut.current() == nil)
  }

  @Test
  func test_cycleCollection_nextIndexEqualToZeroWhenBaseContainsOneItem() {
    var sut = CycleCollection(base: ["item1"], index: 0)
    sut.next()

    #expect(sut.index == 0)
    #expect(sut.base.count - 1 >= sut.index)
  }

  @Test
  func test_cycleCollection_backIndexEqualToZeroWhenBaseContainsOneItem() {
    var sut = CycleCollection(base: ["item1"], index: 0)
    sut.back()

    #expect(sut.index == 0)
    #expect(sut.base.count - 1 >= sut.index)
  }

  @Test
  func test_cycleCollection_nextIndexIncreasedByOneWhenBaseContainsMultipleItems() {
    var sut = CycleCollection(base: ["item1", "item2"], index: 0)
    sut.next()

    #expect(sut.index == 1)
    #expect(sut.base.count - 1 >= sut.index)
  }

  @Test
  func test_cycleCollection_backIndexDecreasedByOneWhenBaseContainsMultipleItems() {
    var sut = CycleCollection(base: ["item1", "item2"], index: 1)
    sut.back()

    #expect(sut.index == 0)
    #expect(sut.base.count - 1 >= sut.index)
  }

  @Test
  func test_cycleCollection_nextIndexWhenIndexWrapsAround() {
    var sut = CycleCollection(base: ["item1", "item2"], index: 1)
    sut.next()

    #expect(sut.index == 0)
    #expect(sut.base.count - 1 >= sut.index)
  }

  @Test
  func test_cycleCollection_backIndexWhenIndexWrapsAround() {
    var sut = CycleCollection(base: ["item1", "item2"], index: 0)
    sut.back()

    #expect(sut.index == 1)
    #expect(sut.base.count - 1 >= sut.index)
  }

  @Test
  func test_cycleCollection_initResetsIndexWhenIndexIsOutOfRange() {
    let sut = CycleCollection(base: ["item1", "item2"], index: 10)

    #expect(sut.index == 0)
    #expect(sut.current() == "item1")
  }
}
