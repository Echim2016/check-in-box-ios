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
    
    public init(featureCards: IdentifiedArrayOf<FeatureCard> = []) {
      self.featureCards = featureCards
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
    WithViewStore(self.store, observe: { $0.featureCards }) { store in
      ScrollView {
        Spacer()
        ForEach(store.state) { card in
          NavigationLink(
            state: AppFeature.Path.State.classic(ClassicCheckInFeature.State())
          ) {
            FeatureCardView(title: card.title, subtitle: card.subtitle)
              .cornerRadius(16)
          }
          .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
      }
      .navigationTitle("Check it out.")
    }
  }
}

public struct FeatureCard: Equatable, Identifiable {
  public let id: UUID
  public let title: String
  public let subtitle: String
}

#Preview {
  NavigationStack {
    ModeListView(
      store: Store(
        initialState: ModeListFeature.State(
          featureCards: [
            FeatureCard(id: UUID(), title: "經典模式", subtitle: "Check-in Box"),
          ]
        )
      ) {
        ModeListFeature()
      }
    )
  }
  .preferredColorScheme(.dark)
}
