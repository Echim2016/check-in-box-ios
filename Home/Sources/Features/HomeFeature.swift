//
//  HomeFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/15.
//

@preconcurrency import CBFoundation
import ComposableArchitecture
import FirebaseService
import SwiftUI

@Reducer
public struct HomeFeature {
  @ObservableState
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

  public enum Action {
    case path(StackAction<Path.State, Path.Action>)
    case modeList(ModeListFeature.Action)
    case loadFromRemote
    case receivedQuestions(IdentifiedArrayOf<ThemeBox>, IdentifiedArrayOf<Tag>, IdentifiedArrayOf<Question>)
  }
  
  @Reducer
  public enum Path {
    case classic(ClassicCheckInFeature)
  }

  public init() {}

  @Dependency(\.debugModeManager) var debugModeManager
  @Dependency(\.firebaseCheckInLoader) var firebaseCheckInLoader

  public var body: some ReducerOf<Self> {
    Scope(state: \.modeList, action: \.modeList) {
      ModeListFeature()
    }

    Reduce { state, action in
      switch action {
      case .modeList(.pullToRefreshTriggered):
        return .send(.loadFromRemote)
        
      case let .modeList(.navigateToCheckInPage(checkInState)):
        state.path.append(.classic(checkInState))
        return .none

      case .modeList:
        return .none

      case .loadFromRemote:
        return .run { send in
          let isFullAccess = debugModeManager.isFullAccess("admin_full_access")
          async let themeBoxes = firebaseCheckInLoader.loadThemeBoxes("Theme_Boxes", isFullAccess)
          async let tags = firebaseCheckInLoader.loadTags("Question_Tags")
          async let questions = firebaseCheckInLoader.loadQuestions("Questions")

          try await send(
            .receivedQuestions(
              themeBoxes,
              tags,
              questions
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
    .forEach(\.path, action: \.path)
  }
}

public struct HomeView: View {
  @Bindable var store: StoreOf<HomeFeature>

  public init(store: StoreOf<HomeFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack(
      path: $store.scope(state: \.path, action: \.path)
    ) {
      ModeListView(store: store.scope(state: \.modeList, action: \.modeList))
        .preferredColorScheme(.dark)
    } destination: { store in
      switch store.case {
      case let .classic(store):
        ClassicCheckInView(store: store)
      }
    }
    .task {
      store.send(.loadFromRemote)
    }
    .tint(.white)
  }
}

extension HomeFeature.Path.State: Equatable {}

#Preview {
  HomeView(
    store: Store(
      initialState: HomeFeature.State(
        modeList: ModeListFeature.State()
      )
    ) {
      HomeFeature()
        ._printChanges()
    }
  )
}
