//
//  InfoSheetFeatureTests.swift
//  
//
//  Created by Yi-Chin Hsu on 2024/1/9.
//

import ComposableArchitecture
@testable import Features
import XCTest


@MainActor
final class InfoSheetFeatureTests: XCTestCase {
  
  func test_doneButton_trackClickingEventWhenTapped() async {
    let store = makeSUT()
    store.arrangeTracker(for: .clickInfoIntroPgDoneBtn(parameters: [:]))
    
    await store.send(.doneButtonTapped)
  }
  
  func test_introPage_trackViewEvent() async {
    let store = makeSUT()
    store.arrangeTracker(for: .viewInfoIntroPg(parameters: [:]))
    
    await store.send(.trackViewInfoIntroEvent)
  }
  
  func makeSUT() -> TestStoreOf<InfoSheetFeature> {
    TestStore(
      initialState: InfoSheetFeature.State(),
      reducer: { InfoSheetFeature() }
    ) {
      $0.firebaseTracker = FirebaseTracker(
        logEvent: { event in
          XCTFail("\(event) is not handled")
        }
      )
    }
  }
}
