//
//  ModeListFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/15.
//

import ComposableArchitecture
import SwiftUI

public struct ModeListFeature: Reducer {
  public struct State: Equatable {
    @PresentationState var presentSettingsPage: SettingsFeature.State?
    var featureCards: IdentifiedArrayOf<FeatureCard> = []
    var questions: [String]

    public init(
      presentSettingsPage: SettingsFeature.State? = nil,
      featureCards: IdentifiedArrayOf<FeatureCard> = [],
      questions: [String] = []
    ) {
      self.presentSettingsPage = presentSettingsPage
      self.featureCards = featureCards
      self.questions = questions
    }
  }

  public enum Action: Equatable {
    case settingsButtonTapped
    case settingsSheetDoneButtonTapped
    case presentSettingsPage(PresentationAction<SettingsFeature.Action>)
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .settingsButtonTapped:
        state.presentSettingsPage = SettingsFeature.State()
        return .none
      case .settingsSheetDoneButtonTapped:
        state.presentSettingsPage = nil
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
            store.send(.settingsButtonTapped)
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
      ) { settingsViewStore in
        NavigationStack {
          SettingsView(store: settingsViewStore)
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
              ToolbarItem {
                Button("完成") {
                  store.send(.settingsSheetDoneButtonTapped)
                }
                .foregroundStyle(.white)
              }
            }
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
