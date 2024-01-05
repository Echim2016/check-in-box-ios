//
//  ClassicFeatureTests.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/21.
//

import ComposableArchitecture
@testable import Features
import XCTest

@MainActor
final class ClassicFeatureTests: XCTestCase {
  func test_classicCheckIn_pickedQuestionFromDefaultState() async {
    let questions = getMockMultipleCheckInItems()
    let store = makeSUT(base: questions)
    arrangeTrackerOf(
      store,
      event: .clickClassicCheckInPgPickBtn(
        parameters: [
          "theme": "Test",
          "current_content": questions.first?.content,
          "current_index": 0,
          "items_total_count": questions.count,
        ]
      )
    )

    await store.send(.pickButtonTapped) {
      $0.displayQuestion = questions[1].content
    }
  }

  func test_classicCheckIn_pickedQuestionFromLastIndex() async {
    let questions = getMockMultipleCheckInItems()
    let lastIndex = questions.count - 1
    let store = makeSUT(base: questions, index: lastIndex)
    arrangeTrackerOf(
      store,
      event: .clickClassicCheckInPgPickBtn(
        parameters: [
          "theme": "Test",
          "current_content": questions[lastIndex].content,
          "current_index": lastIndex,
          "items_total_count": questions.count,
        ]
      )
    )

    await store.send(.pickButtonTapped) {
      $0.displayQuestion = questions.first?.content
    }
  }

  func test_classicCheckIn_pickedPreviousQuestionFromDefaultState() async {
    let questions = getMockMultipleCheckInItems()
    let store = makeSUT(base: questions)
    arrangeTrackerOf(
      store,
      event: .clickClassicCheckInPgPreviousBtn(
        parameters: [
          "theme": "Test",
          "current_content": questions.first?.content,
          "current_index": 0,
          "items_total_count": questions.count,
        ]
      )
    )

    await store.send(.previousButtonTapped) {
      $0.displayQuestion = questions.last?.content
    }
  }

  func test_classicCheckIn_trackViewEvent() async {
    let store = makeSUT(base: [])
    store.dependencies.firebaseTracker = FirebaseTracker(
      logEvent: { event in
        XCTAssertEqual(event, .viewClassicCheckInPg(parameters: ["theme": "Test"]))
      }
    )

    await store.send(.trackViewClassicCheckInPageEvent)
  }

  func makeSUT(base: [CheckInItem], index: Int = 0) -> TestStore<ClassicCheckInFeature.State, ClassicCheckInFeature.Action> {
    let store = TestStore(
      initialState: ClassicCheckInFeature.State(
        theme: "Test",
        questions: CycleIterator(base: base, index: index)
      ),
      reducer: { ClassicCheckInFeature() }
    ) {
      $0.firebaseTracker = FirebaseTracker(
        logEvent: { event in
          XCTFail("\(event) is not handled")
        }
      )
    }
    return store
  }
  
  func arrangeTrackerOf(
    _ store: TestStoreOf<ClassicCheckInFeature>,
    event: FirebaseEvent?
  ) {
    store.dependencies.firebaseTracker = FirebaseTracker(
      logEvent: { trackingEvent in
        if let event {
          XCTAssertEqual(trackingEvent, event)
        }
      }
    )
  }
}
