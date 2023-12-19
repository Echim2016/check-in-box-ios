import ComposableArchitecture
@testable import Features
import XCTest

@MainActor
final class AppFeaturesTests: XCTestCase {
  func test_path_navigateToClassicPage() async {
    let store = TestStore(
      initialState: AppFeature.State(modeList: ModeListFeature.State(featureCards: FeatureCard.default))
    ) {
      AppFeature()
    }

    await store.send(.path(.push(id: 0, state: .classic(ClassicCheckInFeature.State())))) {
      $0.path[id: 0] = .classic(ClassicCheckInFeature.State())
    }
  }
  
  func test_cycleIterator_equatable() {
    let sut1 = CycleIterator(base: ["sut"], index: 0)
    let sut2 = CycleIterator(base: ["sut"], index: 1)
    
    XCTAssertNotEqual(sut1, sut2)
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
  
  func test_cycleIterator_nextIndexAddedWhenBaseContainsMultipleItems() {
    let sut = CycleIterator(base: ["item1", "item2"], index: 0)
    sut.next()
    
    XCTAssertEqual(sut.index, 1)
    XCTAssertGreaterThanOrEqual(sut.base.count - 1, sut.index)
  }
  
  func test_cycleIterator_backIndexAddedWhenBaseContainsMultipleItems() {
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
}
