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
    var themeBoxes: IdentifiedArrayOf<ThemeBox> = []
    var questions: IdentifiedArrayOf<Question>
    var tags: IdentifiedArrayOf<Tag>

    public init(
      presentSettingsPage: SettingsFeature.State? = nil,
      themeBoxes: IdentifiedArrayOf<ThemeBox> = [],
      questions: IdentifiedArrayOf<Question> = [],
      tags: IdentifiedArrayOf<Tag> = []
    ) {
      self.presentSettingsPage = presentSettingsPage
      self.themeBoxes = themeBoxes
      self.questions = questions
      self.tags = tags
    }
  }

  public enum Action: Equatable {
    case settingsButtonTapped
    case settingsSheetDoneButtonTapped
    case presentSettingsPage(PresentationAction<SettingsFeature.Action>)
    case pullToRefreshTriggered
    case trackViewModeListEvent
  }
  
  @Dependency(\.firebaseTracker) var firebaseTracker

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .settingsButtonTapped:
        state.presentSettingsPage = SettingsFeature.State()
        return .none
      case .settingsSheetDoneButtonTapped:
        state.presentSettingsPage = nil
        return .none
        
      case .presentSettingsPage(.dismiss):
        firebaseTracker.logEvent(.viewModeListPg(parameters: [:]))
        return .none
        
      case .presentSettingsPage:
        return .none
      case .pullToRefreshTriggered:
        return .none
      case .trackViewModeListEvent:
        firebaseTracker.logEvent(.viewModeListPg(parameters: [:]))
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

        ScrollView(.horizontal) {
          HStack {
            ForEach(store.state.themeBoxes) { box in
              NavigationLink(
                state: AppFeature.Path.State.classic(
                  ClassicCheckInFeature.State(
                    alert: AlertState(
                      title: TextState(verbatim: box.alertTitle),
                      message: TextState(verbatim: box.alertMessage.replacingOccurrences(of: "\\n", with: "\n")),
                      buttons: [
                        ButtonState(
                          action: .welcomeMessageDoneButtonTapped,
                          label: {
                            TextState("好")
                          }
                        )
                      ]
                    ),
                    theme: box.title,
                    questions: CycleIterator(
                      base: box.items.items
                        .map { CheckInItem.from($0) }
                        .shuffled()
                    ),
                    imageUrl: URL(string: box.imageUrl)
                  )
                )
              ) {
                ThemeBoxCardView(
                  title: box.title,
                  subtitle: box.subtitle,
                  url: URL(string: box.imageUrl)
                )
                .frame(width: 340, height: 200)
                .cornerRadius(16)
              }
              .buttonStyle(PlainButtonStyle())
            }
          }
          .padding(.horizontal)
        }
        .scrollIndicators(.hidden)

        if store.state.tags.isEmpty {
          ProgressView()
            .padding(.top, 100)

        } else {
          Spacer()
          HStack {
            Text("精選類別")
              .font(.title3)
              .fontWeight(.heavy)
            Spacer()
          }
          .padding(.top, 20)
          .padding(.horizontal)

          LazyVGrid(columns: gridItemLayout, spacing: 8) {
            ForEach(store.state.tags) { tag in
              NavigationLink(
                state: AppFeature.Path.State.classic(
                  ClassicCheckInFeature.State(
                    theme: tag.title,
                    questions: CycleIterator(
                      base: store.state.questions
                        .filter(by: tag.code)
                        .map { CheckInItem.from($0) }
                        .shuffled()
                    )
                  )
                )
              ) {
                FeatureCardView(title: tag.title.capitalized, subtitle: tag.subtitle)
                  .cornerRadius(16)
              }
              .buttonStyle(PlainButtonStyle())
            }
          }
          .padding(.horizontal)
        }
      }
      .navigationTitle("Check! 🥂")
      .refreshable {
        // TODO: async refreshable
        do {
          try await Task.sleep(until: .now + .seconds(0.6), clock: .continuous)
          store.send(.pullToRefreshTriggered)
        } catch {}
      }
      .onAppear {
        store.send(.trackViewModeListEvent)
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

private extension IdentifiedArray where Element == Question {
  func filter(by tag: String) -> [Element] {
    guard !tag.isEmpty else { return elements }
    return compactMap {
      $0.tags.contains(tag) ? $0 : nil
    }
  }
}

#Preview {
  NavigationStack {
    ModeListView(
      store: Store(
        initialState: ModeListFeature.State()
      ) {
        ModeListFeature()
      }
    )
  }
  .preferredColorScheme(.dark)
}
