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

  public enum Action: Equatable {
    case path(StackAction<Path.State, Path.Action>)
    case modeList(ModeListFeature.Action)
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

  public var body: some ReducerOf<Self> {
    Scope(state: \.modeList, action: /Action.modeList) {
      ModeListFeature()
    }

    Reduce { _, action in
      switch action {
      case .modeList:
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
    .tint(.white)
  }
}

#Preview {
  AppView(
    store: Store(
      initialState: AppFeature.State(
        modeList: ModeListFeature.State(
          featureCards: FeatureCard.default
        )
      )
    ) {
      AppFeature()
        ._printChanges()
    }
  )
}
