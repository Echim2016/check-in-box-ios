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

  func test_classicCheckIn_urlButtonTappedForValidUrl() async {
    let testUrl = "https://test.com"
    let questions = [
      CheckInItem(id: "1", content: "content", url: testUrl),
    ]
    let store = makeSUT(base: questions)
    arrangeTrackerOf(
      store,
      event: .clickClassicCheckInPgUrlBtn(
        parameters: [
          "theme": "Test",
          "current_content": questions.first?.content,
          "url": testUrl,
        ]
      )
    )
    arrangeOpenUrlOf(store, destinationUrl: URL(string: testUrl)!)

    await store.send(.urlButtonTapped)
  }

  func test_classicCheckIn_urlButtonTappedForInvalidUrl() async {
    let invalidUrl = ""
    let questions = [
      CheckInItem(id: "1", content: "content", url: invalidUrl),
    ]
    let store = makeSUT(base: questions)

    await store.send(.urlButtonTapped)
  }

  func test_classicCheckIn_welcomeMessageAlertDoneButtonTapped() async {
    let alert = AlertState<ClassicCheckInFeature.Action.Alert>(
      title: TextState(verbatim: "Alert title"),
      message: TextState(verbatim: "welcome message"),
      buttons: [
        ButtonState(
          action: .welcomeMessageDoneButtonTapped,
          label: {
            TextState("好")
          }
        ),
      ]
    )
    let store = TestStore(
      initialState: ClassicCheckInFeature.State(
        alert: alert,
        theme: "Test",
        questions: CycleIterator(base: [])
      )
    ) {
      ClassicCheckInFeature()
    }

    arrangeTrackerOf(
      store,
      event: .clickClassicCheckInPgWelcomeMessageDoneBtn(
        parameters: [
          "theme": "Test",
        ]
      )
    )

    await store.send(.alert(.presented(.welcomeMessageDoneButtonTapped))) {
      $0.alert = nil
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

  func arrangeOpenUrlOf(
    _ store: TestStoreOf<ClassicCheckInFeature>,
    destinationUrl: URL
  ) {
    store.dependencies.openURL = OpenURLEffect(
      handler: { url in
        XCTAssertEqual(url, destinationUrl)
        return true
      }
    )
  }

  func arrangeTrackerOf(
    _ store: TestStoreOf<ClassicCheckInFeature>,
    event: FirebaseEvent
  ) {
    store.dependencies.firebaseTracker = FirebaseTracker(
      logEvent: { trackingEvent in
        XCTAssertEqual(trackingEvent, event)
      }
    )
  }
}
