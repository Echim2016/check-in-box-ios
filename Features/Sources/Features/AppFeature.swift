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
    case receivedQuestions(IdentifiedArrayOf<ThemeBox>, IdentifiedArrayOf<Tag>, IdentifiedArrayOf<Question>)
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

  @Dependency(\.debugModeManager) var debugModeManager
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
              await firebaseCheckInLoader.loadThemeBoxes("Theme_Boxes", debugModeManager.isFullAccess("admin_full_access")),
              await firebaseCheckInLoader.loadTags("Question_Tags"),
              await firebaseCheckInLoader.loadQuestions("Questions")
            )
          )
        }
        
      case let .receivedQuestions(themeBoxes, tags, questions):
        state.modeList.themeBoxes = themeBoxes
        state.modeList.tags = tags
        state.modeList.questions = questions
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
