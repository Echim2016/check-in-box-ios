//
//  ModeListFeatureTests.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/21.
//

import ComposableArchitecture
@testable import Features
import XCTest

@MainActor
final class ModeListFeatureTests: XCTestCase {
  func test_settingsSheet_presentedWhenSettingButtonTapped() async {
    let store = makeSUT()

    await store.send(.settingsButtonTapped) {
      $0.presentSettingsPage = SettingsFeature.State()
    }
  }

  func test_settingsSheet_dismissedWhenDoneButtonTapped() async {
    let store = makeSUT(of: ModeListFeature.State(presentSettingsPage: SettingsFeature.State()))
    store.arrangeTracker(for: .viewModeListPg(parameters: [:]))

    await store.send(.settingsSheetDoneButtonTapped) {
      $0.presentSettingsPage = nil
    }
  }

  func test_settingsSheet_dismissed() async {
    let store = makeSUT(of: ModeListFeature.State(presentSettingsPage: SettingsFeature.State()))
    store.arrangeTracker(for: .viewModeListPg(parameters: [:]))

    await store.send(.presentSettingsPage(.dismiss)) {
      $0.presentSettingsPage = nil
    }
  }

  func test_infoIntroSheet_presentedWhenInfoButtonTapped() async {
    let store = makeSUT()

    await store.send(.infoButtonTapped) {
      $0.presentInfoPage = InfoSheetFeature.State()
    }
  }

  func test_infoIntroSheet_dismissedWhenDoneButtonTapped() async {
    let store = makeSUT(of: ModeListFeature.State(presentInfoPage: InfoSheetFeature.State()))
    store.arrangeTracker(for: .clickInfoIntroPgDoneBtn(parameters: [:]), .viewModeListPg(parameters: [:]))

    await store.send(.presentInfoPage(.presented(.doneButtonTapped))) {
      $0.presentInfoPage = nil
      $0.hapticFeedbackTrigger = true
    }
  }

  func test_questions_reloadWhenPullToRefresh() async {
    let questions = IdentifiedArray(uniqueElements: getMockMultipleQuestions())
    let tags = IdentifiedArray(uniqueElements: getMockTags())
    let themeBoxes = IdentifiedArray(uniqueElements: getMockThemeBoxes())

    let store = TestStore(
      initialState: AppFeature.State(modeList: ModeListFeature.State()),
      reducer: { AppFeature() }
    ) {
      $0.firebaseCheckInLoader = FirebaseCheckInLoader(
        loadQuestions: { _ in
          questions
        },
        loadTags: { _ in
          tags
        },
        loadThemeBoxes: { _, _ in
          themeBoxes
        }
      )
      $0.debugModeManager = DebugModeManager(
        isFullAccess: { _ in
          true
        },
        setAccess: { _ in }
      )
    }

    await store.send(.loadFromRemote)
    await store.receive(.receivedQuestions(themeBoxes, tags, questions)) {
      $0.modeList.themeBoxes = themeBoxes
      $0.modeList.tags = tags
      $0.modeList.questions = questions
    }

    let updatedQuestions: IdentifiedArrayOf<Question> = []
    let updatedTags: IdentifiedArrayOf<Tag> = []
    let updatedThemeBoxes: IdentifiedArrayOf<ThemeBox> = []
    store.dependencies.firebaseCheckInLoader = FirebaseCheckInLoader(
      loadQuestions: { _ in
        updatedQuestions
      },
      loadTags: { _ in
        updatedTags
      },
      loadThemeBoxes: { _, _ in
        updatedThemeBoxes
      }
    )

    await store.send(.modeList(.pullToRefreshTriggered))
    await store.receive(.loadFromRemote)
    await store.receive(.receivedQuestions(updatedThemeBoxes, updatedTags, updatedQuestions)) {
      $0.modeList.themeBoxes = updatedThemeBoxes
      $0.modeList.tags = updatedTags
      $0.modeList.questions = updatedQuestions
    }
  }

  func test_modeList_trackViewEvent() async {
    let store = TestStore(
      initialState: ModeListFeature.State(),
      reducer: { ModeListFeature() }
    ) {
      $0.firebaseTracker = FirebaseTracker(
        logEvent: { event in
          XCTAssertEqual(event, .viewModeListPg(parameters: [:]))
        }
      )
    }

    await store.send(.trackViewModeListEvent)
  }

  func test_modeList_trackClickThemeBoxEvent() async {
    let box = getMockThemeBox()
    let store = TestStore(
      initialState: ModeListFeature.State(),
      reducer: { ModeListFeature() }
    ) {
      $0.firebaseTracker = FirebaseTracker(
        logEvent: { event in
          XCTAssertEqual(event, .clickModeListPgThemeBoxCard(
            parameters: [
              "theme": box.code,
              "order": box.order,
            ]
          ))
        }
      )
      $0.itemRandomizer = ItemRandomizer(
        shuffleHandler: { items in
          items
        }
      )
    }

    await store.send(.themeBoxCardTapped(box))
    await store.receive(
      .navigateToCheckInPage(
        ClassicCheckInFeature.State(
          alert: AlertState(
            title: TextState(verbatim: box.alertTitle),
            message: TextState(verbatim: box.alertMessage.replacingOccurrences(of: "\\n", with: "\n")),
            buttons: [
              ButtonState(
                action: .welcomeMessageDoneButtonTapped,
                label: {
                  TextState("好")
                }
              ),
            ]
          ),
          tag: .from(box),
          questions: CycleIterator(
            base: box.items.items.map { CheckInItem.from($0) }
          ),
          imageUrl: URL(string: box.imageUrl)
        )
      )
    )
  }

  func test_modeList_trackClickCheckInCardEvent() async {
    let tag = Tag(order: 1, code: "Test")
    let store = TestStore(
      initialState: ModeListFeature.State(),
      reducer: { ModeListFeature() }
    ) {
      $0.firebaseTracker = FirebaseTracker(
        logEvent: { event in
          XCTAssertEqual(event, .clickModeListPgCheckInCard(
            parameters: [
              "theme": tag.code,
              "order": tag.order,
            ]
          ))
        }
      )
      $0.itemRandomizer = ItemRandomizer(
        shuffleHandler: { items in
          items
        }
      )
    }

    await store.send(.checkInCardTapped(tag))
    await store.receive(
      .navigateToCheckInPage(
        ClassicCheckInFeature.State(
          tag: tag,
          questions: CycleIterator(
            base: []
          )
        )
      )
    )
  }

  func makeSUT(of state: ModeListFeature.State = ModeListFeature.State()) -> TestStoreOf<ModeListFeature> {
    TestStore(
      initialState: state,
      reducer: { ModeListFeature() }
    ) {
      $0.firebaseTracker = FirebaseTracker(
        logEvent: { event in
          XCTFail("\(event) is not handled")
        }
      )
    }
  }
}
