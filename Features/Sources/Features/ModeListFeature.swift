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
    @PresentationState var presentInfoPage: InfoSheetFeature.State?
    var themeBoxes: IdentifiedArrayOf<ThemeBox> = []
    var questions: IdentifiedArrayOf<Question>
    var tags: IdentifiedArrayOf<Tag>
    var hapticFeedbackTrigger: Bool = false

    public init(
      presentSettingsPage: SettingsFeature.State? = nil,
      presentInfoPage: InfoSheetFeature.State? = nil,
      themeBoxes: IdentifiedArrayOf<ThemeBox> = [],
      questions: IdentifiedArrayOf<Question> = [],
      tags: IdentifiedArrayOf<Tag> = [],
      hapticFeedbackTrigger: Bool = false
    ) {
      self.presentSettingsPage = presentSettingsPage
      self.presentInfoPage = presentInfoPage
      self.themeBoxes = themeBoxes
      self.questions = questions
      self.tags = tags
      self.hapticFeedbackTrigger = hapticFeedbackTrigger
    }
  }

  public enum Action: Equatable {
    case checkInCardTapped(Tag)
    case themeBoxCardTapped(ThemeBox)
    case navigateToCheckInPage(ClassicCheckInFeature.State)
    case settingsButtonTapped
    case settingsSheetDoneButtonTapped
    case presentSettingsPage(PresentationAction<SettingsFeature.Action>)
    case infoButtonTapped
    case presentInfoPage(PresentationAction<InfoSheetFeature.Action>)
    case pullToRefreshTriggered
    case trackViewModeListEvent
  }

  @Dependency(\.firebaseTracker) var firebaseTracker
  @Dependency(\.itemRandomizer) var itemRandomizer

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .checkInCardTapped(tag):
        firebaseTracker.logEvent(
          .clickModeListPgCheckInCard(
            parameters: [
              "theme": tag.code,
              "order": tag.order,
            ]
          )
        )
        let base = itemRandomizer
          .shuffling(
            state.questions
              .filter(by: tag.code)
              .map { CheckInItem.from($0) }
          )
        
        return .send(
          .navigateToCheckInPage(
            ClassicCheckInFeature.State(
              tag: tag,
              questions: CycleIterator(base: base)
            )
          )
        )

      case let .themeBoxCardTapped(box):
        firebaseTracker.logEvent(
          .clickModeListPgThemeBoxCard(
            parameters: [
              "theme": box.code,
              "order": box.order,
            ]
          )
        )
        
        let base: [CheckInItem] = {
          let items = box.items.items
          let isShufflingNeeded = items.allSatisfy { $0.order == 1 }
          
          if isShufflingNeeded {
            return itemRandomizer
              .shuffling(
                items.map { CheckInItem.from($0) }
              )
          } else {
            return items
              .sorted { $0.order < $1.order }
              .map { CheckInItem.from($0) }
          }
        }()
        
        return .send(
          .navigateToCheckInPage(
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
                  ),
                ]
              ),
              tag: .from(box),
              questions: CycleIterator(base: base),
              imageUrl: URL(string: box.imageUrl)
            )
          )
        )

      case .navigateToCheckInPage:
        return .none

      case .settingsButtonTapped:
        state.presentSettingsPage = SettingsFeature.State()
        return .none
      case .settingsSheetDoneButtonTapped:
        state.presentSettingsPage = nil
        firebaseTracker.logEvent(.viewModeListPg(parameters: [:]))
        return .none

      case .presentSettingsPage(.dismiss):
        firebaseTracker.logEvent(.viewModeListPg(parameters: [:]))
        return .none

      case .presentSettingsPage:
        return .none

      case .infoButtonTapped:
        state.presentInfoPage = InfoSheetFeature.State()
        return .none

      case .presentInfoPage(.presented(.doneButtonTapped)):
        state.presentInfoPage = nil
        state.hapticFeedbackTrigger.toggle()
        firebaseTracker.logEvent(.viewModeListPg(parameters: [:]))
        UserDefaults.standard.setValue(true, forKey: "info-intro-checked")
        return .none

      case .presentInfoPage:
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
    .ifLet(\.$presentInfoPage, action: /Action.presentInfoPage) {
      InfoSheetFeature()
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
              Button {
                store.send(.themeBoxCardTapped(box))
              } label: {
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
              Button {
                store.send(.checkInCardTapped(tag))
              } label: {
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
      .sensoryFeedback(.success, trigger: store.state.hapticFeedbackTrigger)
      .toolbar {
        ToolbarItem {
          Button {
            store.send(.infoButtonTapped)

          } label: {
            Image(systemName: "info.circle")
              .foregroundStyle(.white)
          }
        }

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
      .sheet(
        store: self.store.scope(
          state: \.$presentInfoPage,
          action: { .presentInfoPage($0) }
        )
      ) { infoViewStore in
        InfoSheetView(store: infoViewStore)
          .presentationDetents([.height(600)])
          .interactiveDismissDisabled()
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
