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
    var questions: IdentifiedArrayOf<Question>
    var tags: IdentifiedArrayOf<Tag>

    public init(
      presentSettingsPage: SettingsFeature.State? = nil,
      featureCards: IdentifiedArrayOf<FeatureCard> = [],
      questions: IdentifiedArrayOf<Question> = [],
      tags: IdentifiedArrayOf<Tag> = []
    ) {
      self.presentSettingsPage = presentSettingsPage
      self.featureCards = featureCards
      self.questions = questions
      self.tags = tags
    }
  }

  public enum Action: Equatable {
    case settingsButtonTapped
    case settingsSheetDoneButtonTapped
    case presentSettingsPage(PresentationAction<SettingsFeature.Action>)
    case pullToRefreshTriggered
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
      case .pullToRefreshTriggered:
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
  let gridItemLayout = [GridItem(.flexible()), GridItem(.flexible())]

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

        Spacer()
        HStack {
          Text("精選類別")
            .font(.title3)
            .fontWeight(.heavy)
          Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal)

        LazyVGrid(columns: gridItemLayout, spacing: 12) {
          ForEach(store.state.tags) { tag in
            NavigationLink(
              state: AppFeature.Path.State.classic(
                ClassicCheckInFeature.State(
                  questions: CycleIterator(
                    base: store.state.questions
                      .compactMap { $0.tags.contains(tag.code) ? $0 : nil }
                      .shuffled()
                  )
                )
              )
            ) {
              FeatureCardView(title: tag.title.capitalized, subtitle: "")
                .cornerRadius(16)
            }
            .buttonStyle(PlainButtonStyle())
          }
        }
        .padding(.horizontal)
      }
      .navigationTitle("Let's check! 🔮")
      .refreshable {
        // TODO: async refreshable
        store.send(.pullToRefreshTriggered)
      }
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
