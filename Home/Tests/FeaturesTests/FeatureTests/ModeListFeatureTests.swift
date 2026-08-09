//
//  ModeListFeatureTests.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/21.
//

@testable import CBFoundation
import ComposableArchitecture
@testable import FirebaseService
import Foundation
@testable import Home
import Testing

@MainActor
struct ModeListFeatureTests {
  @Test
  func test_settingsSheet_presentedWhenSettingButtonTapped() async {
    let store = makeSUT()

    await store.send(.settingsButtonTapped) {
      $0.presentSettingsPage = SettingsFeature.State()
    }
  }

  @Test
  func test_settingsSheet_dismissedWhenDoneButtonTapped() async {
    let store = makeSUT(of: ModeListFeature.State(presentSettingsPage: SettingsFeature.State()))
    store.arrangeTracker(for: .viewModeListPg(parameters: [:]))

    await store.send(.settingsSheetDoneButtonTapped) {
      $0.presentSettingsPage = nil
    }
  }

  @Test
  func test_settingsSheet_dismissed() async {
    let store = makeSUT(of: ModeListFeature.State(presentSettingsPage: SettingsFeature.State()))
    store.arrangeTracker(for: .viewModeListPg(parameters: [:]))

    await store.send(.presentSettingsPage(.dismiss)) {
      $0.presentSettingsPage = nil
    }
  }

  @Test
  func test_infoIntroSheet_presentedWhenInfoButtonTapped() async {
    let store = makeSUT()

    await store.send(.infoButtonTapped) {
      $0.presentInfoPage = InfoSheetFeature.State()
    }
  }

  @Test
  func test_infoIntroSheet_dismissedWhenDoneButtonTapped() async {
    let store = makeSUT(of: ModeListFeature.State(presentInfoPage: InfoSheetFeature.State()))
    store.arrangeTracker(for: .clickInfoIntroPgDoneBtn(parameters: [:]), .viewModeListPg(parameters: [:]))

    await store.send(.presentInfoPage(.presented(.doneButtonTapped))) {
      $0.presentInfoPage = nil
      $0.hapticFeedbackTrigger = true
    }
  }

  @Test
  func test_questions_reloadWhenPullToRefresh() async {
    let questions = IdentifiedArray(uniqueElements: getMockMultipleQuestions())
    let tags = IdentifiedArray(uniqueElements: getMockTags())
    let themeBoxes = IdentifiedArray(uniqueElements: getMockThemeBoxes())

    let store = TestStore(
      initialState: HomeFeature.State(modeList: ModeListFeature.State()),
      reducer: { HomeFeature() }
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
    await store.receive(\.receivedQuestions) {
      $0.modeList.themeBoxes = themeBoxes
      $0.modeList.tags = tags
      $0.modeList.questions = questions
    }

    let updatedQuestions: IdentifiedArrayOf<Question> = []
    let updatedTags: IdentifiedArrayOf<CBFoundation.Tag> = []
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
    await store.receive(\.loadFromRemote)
    await store.receive(\.receivedQuestions) {
      $0.modeList.themeBoxes = updatedThemeBoxes
      $0.modeList.tags = updatedTags
      $0.modeList.questions = updatedQuestions
    }
  }

  @Test
  func test_modeList_trackViewEvent() async {
    let store = TestStore(
      initialState: ModeListFeature.State(),
      reducer: { ModeListFeature() }
    ) {
      $0.firebaseTracker = FirebaseTracker(
        configure: {},
        logEvent: { event in
          #expect(event == .viewModeListPg(parameters: [:]))
        }
      )
    }

    await store.send(.trackViewModeListEvent)
  }

  @Test
  func test_modeList_trackClickThemeBoxEventWithItemOrders() async {
    let box = getMockThemeBox()
    let store = TestStore(
      initialState: ModeListFeature.State(),
      reducer: { ModeListFeature() }
    ) {
      $0.firebaseTracker = FirebaseTracker(
        configure: {},
        logEvent: { event in
          #expect(event == .clickModeListPgThemeBoxCard(
            parameters: [
              "theme": box.code,
              "order": box.order,
            ]
          ))
        }
      )
      $0.itemRandomizer = ItemRandomizer(
        shuffleHandler: { _ in
          Issue.record("Items should not be shuffled")
          return []
        }
      )
    }

    await store.send(.themeBoxCardTapped(box))
    await store.receive(
      .navigateToCheckInPage(
        ClassicCheckInFeature.State(
          initialAlertContent: .init(title: box.alertTitle, message: box.alertMessage),
          tag: .from(box),
          questions: CycleCollection(
            base: box.items.items.map { CheckInItem.from($0) }
          ),
          imageUrl: URL(string: box.imageUrl)
        )
      )
    )
  }

  @Test
  func test_modeList_trackClickThemeBoxEventWithSameOrders() async {
    let box = getMockThemeBox(withSameItemOrder: 1)
    let store = TestStore(
      initialState: ModeListFeature.State(),
      reducer: { ModeListFeature() }
    ) {
      $0.firebaseTracker = FirebaseTracker(
        configure: {},
        logEvent: { event in
          #expect(event == .clickModeListPgThemeBoxCard(
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
          initialAlertContent: .init(title: box.alertTitle, message: box.alertMessage),
          tag: .from(box),
          questions: CycleCollection(
            base: box.items.items.map { CheckInItem.from($0) }
          ),
          imageUrl: URL(string: box.imageUrl)
        )
      )
    )
  }

  @Test
  func test_modeList_trackClickCheckInCardEvent() async {
    let tag = Tag(order: 1, code: "Test")
    let store = TestStore(
      initialState: ModeListFeature.State(),
      reducer: { ModeListFeature() }
    ) {
      $0.firebaseTracker = FirebaseTracker(
        configure: {},
        logEvent: { event in
          #expect(event == .clickModeListPgCheckInCard(
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
          questions: CycleCollection(
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
        configure: {},
        logEvent: { event in
          Issue.record("\(event) is not handled")
        }
      )
    }
  }
}
