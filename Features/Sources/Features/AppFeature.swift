//
//  AppFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/15.
//

import ComposableArchitecture
import SwiftUI

struct AppFeature: Reducer {
  struct State: Equatable {
    var path = StackState<Path.State>()
    var modeList = ModeListFeature.State()
  }

  enum Action: Equatable {
    case path(StackAction<Path.State, Path.Action>)
    case modeList(ModeListFeature.Action)
  }

  struct Path: Reducer {
    enum State: Equatable {
      case classic(ClassicCheckInFeature.State)
    }

    enum Action: Equatable {
      case classic(ClassicCheckInFeature.Action)
    }

    var body: some ReducerOf<Self> {
      Scope(state: /State.classic, action: /Action.classic) {
        ClassicCheckInFeature()
      }
    }
  }

  var body: some ReducerOf<Self> {
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

struct AppView: View {
  let store: StoreOf<AppFeature>

  var body: some View {
    NavigationStackStore(
      self.store.scope(state: \.path, action: { .path($0) })
    ) {
      ModeListView(
        store: self.store.scope(
          state: \.modeList,
          action: { .modeList($0) }
        )
      )
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
  }
}

#Preview {
  AppView(
    store: Store(
      initialState: AppFeature.State(
        modeList: ModeListFeature.State(
          featureCards: [
            FeatureCard(id: UUID(), title: "經典模式", subtitle: "Check-in Box"),
          ]
        )
      )
    ) {
      AppFeature()
        ._printChanges()
    }
  )
  .preferredColorScheme(.dark)
}
