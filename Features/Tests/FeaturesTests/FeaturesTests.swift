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

  func test_loadQuestions_fromRemoteLoader() async {
    let mockQuestions = getMockMultipleQuestions()
    let store = TestStore(
      initialState: AppFeature.State(modeList: ModeListFeature.State(featureCards: FeatureCard.default)),
      reducer: { AppFeature() }
    ) {
      $0.firebaseCheckInLoader = FirebaseCheckInLoader(
        load: { collectionPath in
          XCTAssertEqual(collectionPath, "Questions")
          return mockQuestions
        }
      )
    }

    await store.send(.loadFromRemote)
    await store.receive(.receivedQuestions(mockQuestions)) {
      $0.modeList.questions = mockQuestions
    }
  }
}

@MainActor
final class ClassicFeatureTests: XCTestCase {
  func test_classicCheckIn_pickedQuestionFromDefaultState() async {
    let questions = getMockMultipleQuestions()
    let store = makeSUT(base: questions)

    await store.send(.pickButtonTapped) {
      $0.displayQuestion = questions[1]
    }
  }

  func test_classicCheckIn_pickedQuestionFromLastIndex() async {
    let questions = getMockMultipleQuestions()
    let store = makeSUT(base: questions, index: questions.count - 1)

    await store.send(.pickButtonTapped) {
      $0.displayQuestion = questions.first
    }
  }

  func test_classicCheckIn_pickedPreviousQuestionFromDefaultState() async {
    let questions = getMockMultipleQuestions()
    let store = makeSUT(base: questions)

    await store.send(.previousButtonTapped) {
      $0.displayQuestion = questions.last
    }
  }

  func makeSUT(base: [String], index: Int = 0) -> TestStore<ClassicCheckInFeature.State, ClassicCheckInFeature.Action> {
    let store = TestStore(
      initialState: ClassicCheckInFeature.State(questions: CycleIterator(base: base, index: index))
    ) {
      ClassicCheckInFeature()
    }
    return store
  }
}

extension XCTestCase {
  func getMockMultipleQuestions() -> [String] {
    [
      "身上使用最久的東西是什麼？",
      "最喜歡的一部電影？",
      "今年最期待的一件事情？",
      "我不為人知的一個奇怪技能",
      "做過最像大人的事情",
      "今年最快樂的回憶",
      "最想再去一次的國家/城市",
    ]
  }
}

@MainActor
final class ModelListFeatureTests: XCTestCase {
  func test_settingsSheet_presentedWhenSettingButtonTapped() async {
    let store = TestStore(
      initialState: ModeListFeature.State(featureCards: FeatureCard.default)
    ) {
      ModeListFeature()
    }

    await store.send(.settingsButtonTapped) {
      $0.presentSettingsPage = SettingsFeature.State()
    }
  }

  func test_settingsSheet_dismissedWhenDoneButtonTapped() async {
    let store = TestStore(
      initialState: ModeListFeature.State(
        presentSettingsPage: SettingsFeature.State(),
        featureCards: FeatureCard.default
      )
    ) {
      ModeListFeature()
    }

    await store.send(.settingsSheetDoneButtonTapped) {
      $0.presentSettingsPage = nil
    }
  }
}

@MainActor
final class UserSettingsFeatureTests: XCTestCase {
  func test_openURL_navigateToFeedbackForm() async {
    let store = TestStore(
      initialState: SettingsFeature.State(),
      reducer: { SettingsFeature() }
    ) {
      $0.openURL = OpenURLEffect(
        handler: { url in
          XCTAssertEqual(url, URL(string: "https://forms.gle/Vr4MjtowWPxBxr5r9")!)
          return true
        }
      )
    }

    await store.send(.sendFeedbackButtonTapped)
  }
}
