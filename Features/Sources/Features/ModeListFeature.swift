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
    var featureCards: IdentifiedArrayOf<FeatureCard> = []
    var questions: [String]

    public init(featureCards: IdentifiedArrayOf<FeatureCard> = [], questions: [String] = []) {
      self.featureCards = featureCards
      self.questions = questions
    }
  }

  public enum Action: Equatable {
    case settingButtonTapped
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, _ in
      .none
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
