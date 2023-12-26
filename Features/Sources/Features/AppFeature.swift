//
//  AppFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/15.
//

import ComposableArchitecture
import SwiftUI

public struct AppFeature: Reducer {
  public struct State: Equatable {
    var path = StackState<Path.State>()
    var modeList = ModeListFeature.State()

    public init(
      path: StackState<Path.State> = StackState<Path.State>(),
      modeList: ModeListFeature.State = ModeListFeature.State()
    ) {
      self.path = path
      self.modeList = modeList
    }
  }

  public enum Action: Sendable, Equatable {
    case path(StackAction<Path.State, Path.Action>)
    case modeList(ModeListFeature.Action)
    case loadFromRemote
    case receivedQuestions(IdentifiedArrayOf<Tag>, IdentifiedArrayOf<Question>)
  }

  public struct Path: Reducer {
    public enum State: Equatable {
      case classic(ClassicCheckInFeature.State)
    }

    public enum Action: Equatable {
      case classic(ClassicCheckInFeature.Action)
    }

    public var body: some ReducerOf<Self> {
      Scope(state: /State.classic, action: /Action.classic) {
        ClassicCheckInFeature()
      }
    }
  }

  public init() {}

  @Dependency(\.firebaseCheckInLoader) var firebaseCheckInLoader

  public var body: some ReducerOf<Self> {
    Scope(state: \.modeList, action: /Action.modeList) {
      ModeListFeature()
    }

    Reduce { state, action in
      switch action {
      case .modeList(.pullToRefreshTriggered):
        return .send(.loadFromRemote)
        
      case .modeList:
        return .none
        
      case .loadFromRemote:
        return .run { send in
          try await send(
            .receivedQuestions(
              await firebaseCheckInLoader.loadTags("Question_Tags"),
              await firebaseCheckInLoader.loadQuestions("Questions")
            )
          )
        }
        
      case let .receivedQuestions(tags, questions):
        state.modeList.tags = tags
        state.modeList.questions = questions
        state.modeList.themeBoxes = [
          ThemeBox(
            id: UUID(),
            title: "年末反思",
            subtitle: "2023 大回顧",
            questions: [
              "今年最滿足的一件事",
              "今年最後悔的一件事",
              "今年對自己感到驕傲的一個時刻",
              "今年最慶幸有做的一件事",
              "今年一個明確的成長",
              "今年一個沒有做到的事情",
              "今年獲得的一個珍貴的建議"
            ],
            authorName: "echim",
            url: "",
            imageUrl: ""
          ),
          ThemeBox(
            id: UUID(),
            title: "年末反思2",
            subtitle: "2023 大回顧",
            questions: [
              "今年最滿足的一件事",
              "今年最後悔的一件事",
              "今年對自己感到驕傲的一個時刻",
              "今年最慶幸有做的一件事",
              "今年一個明確的成長",
              "今年一個沒有做到的事情",
              "今年獲得的一個珍貴的建議"
            ],
            authorName: "echim",
            url: "",
            imageUrl: ""
          )
        ]
        return .none

      case .path:
        return .none
      }
    }
    .forEach(\.path, action: /Action.path) {
      Path()
    }
  }
}

public struct AppView: View {
  let store: StoreOf<AppFeature>

  public init(store: StoreOf<AppFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStackStore(
      self.store.scope(state: \.path, action: { .path($0) })
    ) {
      ModeListView(
        store: self.store.scope(
          state: \.modeList,
          action: { .modeList($0) }
        )
      )
      .preferredColorScheme(.dark)
    } destination: { state in
      switch state {
      case .classic:
        CaseLet(
          /AppFeature.Path.State.classic,
          action: AppFeature.Path.Action.classic,
          then: ClassicCheckInView.init(store:)
        )
      }
    }
    .task {
      store.send(.loadFromRemote)
    }
    .tint(.white)
  }
}

#Preview {
  AppView(
    store: Store(
      initialState: AppFeature.State(
        modeList: ModeListFeature.State()
      )
    ) {
      AppFeature()
        ._printChanges()
    }
  )
}
