//
//  ModeListFeature.swift
//  
//
//  Created by Yi-Chin Hsu on 2023/12/15.
//

import SwiftUI
import ComposableArchitecture

struct ModeListFeature: Reducer {
    struct State: Equatable {
        var featureCards: IdentifiedArrayOf<FeatureCard> = []
    }
    enum Action: Equatable {
        case settingButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}

struct ModeListView: View {
    let store: StoreOf<ModeListFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0.featureCards }) { store in
            NavigationStack {
                ScrollView {
                    Spacer()
                    ForEach(store.state) { card in
                        FeatureCardView(title: card.title, subtitle: card.subtitle)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                .navigationTitle("Check it out.")
            }
        }
    }
}

struct FeatureCard: Equatable, Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
}


#Preview {
    ModeListView(
        store: Store(
            initialState: ModeListFeature.State(
                featureCards: [
                    FeatureCard(id: UUID(), title: "經典模式", subtitle: "Check-in Box")
                ]
            )
        ) {
            ModeListFeature()
        }
    )
    .preferredColorScheme(.dark)
}
