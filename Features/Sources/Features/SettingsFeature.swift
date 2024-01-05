//
//  SettingsFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/20.
//

import ComposableArchitecture
import SwiftUI

public struct SettingsFeature: Reducer {
  public struct State: Equatable {
    @PresentationState var presentGiftCardInputBoxPage: InputBoxFeature.State?
    var feedbackFormUrl: URL = .feedbackFormUrl
    var authorProfileUrl: URL = .authorProfileUrl
    var authorProfileImageUrl: URL? = .authorProfileImageUrl
    var shareLinkUrl: URL = .shareLinkUrl
    var hapticFeedbackTrigger: Bool = false
  }

  public enum Action: Equatable {
    case authorProfileButtonTapped
    case sendFeedbackButtonTapped
    case shareButtonTapped
    case redeemGiftCardButtonTapped
    case presentGiftCardInputBoxPage(PresentationAction<InputBoxFeature.Action>)
    case trackViewSettingsPageEvent
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.giftCardAccessManager) var giftCardAccessManager
  @Dependency(\.firebaseTracker) var firebaseTracker

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .authorProfileButtonTapped:
        firebaseTracker.logEvent(.clickSettingsPgAuthorProfileBtn(parameters: [:]))
        return .run { [state] _ in
          let url = state.authorProfileUrl
          await openURL(url)
        }

      case .shareButtonTapped:
        firebaseTracker.logEvent(.clickSettingsPgShareBtn(parameters: [:]))
        return .none

      case .sendFeedbackButtonTapped:
        firebaseTracker.logEvent(.clickSettingsPgFeedbackFormBtn(parameters: [:]))
        return .run { [state] _ in
          let url = state.feedbackFormUrl
          await openURL(url)
        }

      case .redeemGiftCardButtonTapped:
        state.presentGiftCardInputBoxPage = InputBoxFeature.State()
        return .none

      case let .presentGiftCardInputBoxPage(.presented(.activationKeySubmitted(key))):
        state.presentGiftCardInputBoxPage = nil
        state.hapticFeedbackTrigger.toggle()
        giftCardAccessManager.setAccess(key)
        return .none

      case .presentGiftCardInputBoxPage:
        firebaseTracker.logEvent(.clickSettingsPgGiftCardBtn(parameters: [:]))
        return .none

      case .trackViewSettingsPageEvent:
        firebaseTracker.logEvent(.viewSettingsPg(parameters: [:]))
        return .none
      }
    }
    .ifLet(\.$presentGiftCardInputBoxPage, action: /Action.presentGiftCardInputBoxPage) {
      InputBoxFeature()
    }
  }
}

struct SettingsView: View {
  let store: StoreOf<SettingsFeature>
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { store in
      List {
        Section {
          Button {} label: {
            ShareLink(item: store.state.shareLinkUrl) {
              /// Problem: Slow loading issue after tapping the share link without any UI indication
              /// Solution: Implement wide label for better pressed state indication
              HStack {
                Label("分享給朋友", systemImage: "square.and.arrow.up")
                  .foregroundStyle(.white)
                Spacer()
                  .frame(minWidth: .leastNonzeroMagnitude)
              }
            }
            .simultaneousGesture(
              TapGesture().onEnded {
                store.send(.shareButtonTapped)
              }
            )
          }

          Button {
            store.send(.redeemGiftCardButtonTapped)
          } label: {
            Label("兌換禮物卡", systemImage: "giftcard")
              .foregroundStyle(.white)
          }

          Button {
            store.send(.sendFeedbackButtonTapped)
          } label: {
            Label("回饋真心話", systemImage: "paperplane")
              .foregroundStyle(.white)
          }
        } header: {
          Text("服務")
        }

        Section {
          Button {
            store.send(.authorProfileButtonTapped)
          } label: {
            ProfileCellView(url: store.state.authorProfileImageUrl)
          }
          .padding(.vertical, 2)

        } header: {
          Text("作者")
        }

        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
          Section {
            Text("v\(version)")
              .foregroundStyle(.secondary)
          } header: {
            Text("版本")
          }
        }
      }
      .onAppear {
        store.send(.trackViewSettingsPageEvent)
      }
      .sensoryFeedback(.success, trigger: store.state.hapticFeedbackTrigger)
    }
    .sheet(
      store: self.store.scope(
        state: \.$presentGiftCardInputBoxPage,
        action: { .presentGiftCardInputBoxPage($0) }
      )
    ) { inputBoxViewStore in
      InputBoxView(store: inputBoxViewStore)
        .presentationDetents([.height(180)])
    }
  }
}

#Preview {
  NavigationStack {
    SettingsView(
      store: Store(initialState: SettingsFeature.State()
      ) {
        SettingsFeature()
      }
    )
  }
  .preferredColorScheme(.dark)
}
