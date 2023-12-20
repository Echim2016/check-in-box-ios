//
//  ModeListFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/15.
//

import ComposableArchitecture
import SwiftUI

public struct SettingsFeature: Reducer {
  public struct State: Equatable {}
  public enum Action: Equatable {}

  public var body: some ReducerOf<Self> {
    Reduce { _, _ in
      .none
    }
  }
}

struct SettingsView: View {
  let store: StoreOf<SettingsFeature>
  var body: some View {
    List {
      Section {
        Text("echim.hsu")
      } header: {
        Text("作者")
      }
    }
  }
}

public struct ModeListFeature: Reducer {
  public struct State: Equatable {
    @PresentationState var presentSettingsPage: SettingsFeature.State?
    var featureCards: IdentifiedArrayOf<FeatureCard> = []
    var questions: [String]

    public init(featureCards: IdentifiedArrayOf<FeatureCard> = [], questions: [String] = []) {
      self.featureCards = featureCards
      self.questions = questions
    }
  }

  public enum Action: Equatable {
    case settingButtonTapped
    case presentSettingsPage(PresentationAction<SettingsFeature.Action>)
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .settingButtonTapped:
        state.presentSettingsPage = SettingsFeature.State()
        return .none
      case .presentSettingsPage:
        return .none
      }
    }
    .ifLet(\.$presentSettingsPage, action: /Action.presentSettingsPage) {
      SettingsFeature()
    }
  }
}

struct ModeListView: View {
  let store: StoreOf<ModeListFeature>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { store in
      ScrollView {
        Spacer()
        Spacer()
        ForEach(store.state.featureCards) { card in
          NavigationLink(
            state: AppFeature.Path.State.classic(
              ClassicCheckInFeature.State(
                questions: CycleIterator(base: store.state.questions.shuffled())
              )
            )
          ) {
            FeatureCardView(title: card.title, subtitle: card.subtitle)
              .cornerRadius(16)
          }
          .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
      }
      .navigationTitle("Let's check! 🔮")
      .toolbar {
        ToolbarItem {
          Button {
            store.send(.settingButtonTapped)
          } label: {
            Image(systemName: "gearshape")
              .foregroundStyle(.white)
          }
        }
      }
      .sheet(
        store: self.store.scope(
          state: \.$presentSettingsPage,
          action: { .presentSettingsPage($0) }
        )
      ) { store in
        NavigationStack {
          SettingsView(store: store)
            .navigationTitle("設定")
        }
      }
    }
  }
}

public struct FeatureCard: Equatable, Identifiable {
  public let id: UUID
  public let title: String
  public let subtitle: String

  public static let `default`: IdentifiedArrayOf<FeatureCard> = [
    FeatureCard(id: UUID(), title: "經典模式", subtitle: "Check-in Box"),
  ]
}

#Preview {
  NavigationStack {
    ModeListView(
      store: Store(
        initialState: ModeListFeature.State(
          featureCards: FeatureCard.default
        )
      ) {
        ModeListFeature()
      }
    )
  }
  .preferredColorScheme(.dark)
}
