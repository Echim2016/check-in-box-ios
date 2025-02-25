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
    store.arrangeTracker(
      for: .clickClassicCheckInPgPickBtn(
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
      $0.displaySubtitle = questions[1].subtitle
    }
  }

  func test_classicCheckIn_pickedQuestionFromLastIndex() async {
    let questions = getMockMultipleCheckInItems()
    let lastIndex = questions.count - 1
    let store = makeSUT(base: questions, index: lastIndex)
    store.arrangeTracker(
      for: .clickClassicCheckInPgPickBtn(
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
      $0.displaySubtitle = questions.first?.subtitle
    }
  }

  func test_classicCheckIn_pickedPreviousQuestionFromDefaultState() async {
    let questions = getMockMultipleCheckInItems()
    let store = makeSUT(base: questions)
    store.arrangeTracker(
      for: .clickClassicCheckInPgPreviousBtn(
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
      $0.displaySubtitle = questions.last?.subtitle
    }
  }

  func test_classicCheckIn_urlButtonTappedForValidUrl() async {
    let testUrl = "https://test.com"
    let questions = [
      CheckInItem(content: "content", url: testUrl),
    ]
    let store = makeSUT(base: questions)
    store.arrangeTracker(
      for: .clickClassicCheckInPgUrlBtn(
        parameters: [
          "theme": "Test",
          "current_content": questions.first?.content,
          "url": testUrl,
        ]
      )
    )
    store.arrangeOpenUrl(of: URL(string: testUrl)!)

    await store.send(.urlButtonTapped)
  }

  func test_classicCheckIn_urlButtonTappedForInvalidUrl() async {
    let invalidUrl = ""
    let questions = [
      CheckInItem(content: "content", url: invalidUrl),
    ]
    let store = makeSUT(base: questions)

    await store.send(.urlButtonTapped)
  }

  func test_classicCheckIn_welcomeMessageAlertDoneButtonTapped() async {
    let alert = AlertState(
      title: {
        TextState("Alert title")
      },
      actions: {
        ButtonState(action: ClassicCheckInFeature.Action.Alert.welcomeMessageDoneButtonTapped) {
          TextState("好")
        }
      },
      message: {
        TextState("welcome message")
      }
    )
    let store = TestStore(
      initialState: ClassicCheckInFeature.State(
        alert: alert,
        tag: Tag(code: "Test"),
        questions: CycleIterator(base: [])
      )
    ) {
      ClassicCheckInFeature()
    }
    store.arrangeTracker(
      for: .clickClassicCheckInPgWelcomeMessageDoneBtn(
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
    store.arrangeTracker(
      for: .viewClassicCheckInPg(
        parameters: [
          "theme": "Test",
          "order": -1,
        ]
      )
    )

    await store.send(.trackViewClassicCheckInPageEvent)
  }

  func makeSUT(base: [CheckInItem], index: Int = 0) -> TestStore<ClassicCheckInFeature.State, ClassicCheckInFeature.Action> {
    let store = TestStore(
      initialState: ClassicCheckInFeature.State(
        tag: Tag(code: "Test"),
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
}
