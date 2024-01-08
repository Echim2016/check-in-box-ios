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
    @PresentationState var presentInAppWebViewPage: InAppWebFeature.State?
    var feedbackFormUrl: URL = .feedbackFormUrl
    var authorProfileUrl: URL = .authorProfileUrl
    var authorProfileImageUrl: URL? = .authorProfileImageUrl
    var shareLinkUrl: URL = .shareLinkUrl
    var submitQuestionsUrl: URL = .submitQuestionsUrl
    var hapticFeedbackTrigger: Bool = false
  }

  public enum Action: Equatable {
    case authorProfileButtonTapped
    case sendFeedbackButtonTapped
    case shareButtonTapped
    case redeemGiftCardButtonTapped
    case submitQuestionsButtonTapped
    case presentGiftCardInputBoxPage(PresentationAction<InputBoxFeature.Action>)
    case presentInAppWebViewPage(PresentationAction<InAppWebFeature.Action>)
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
        state.presentInAppWebViewPage = InAppWebFeature.State(url: .feedbackFormUrl)
        return .none

      case .redeemGiftCardButtonTapped:
        firebaseTracker.logEvent(.clickSettingsPgGiftCardBtn(parameters: [:]))
        state.presentGiftCardInputBoxPage = InputBoxFeature.State()
        return .none

      case .submitQuestionsButtonTapped:
        firebaseTracker.logEvent(.clickSettingsPgSubmitQuestionsBtn(parameters: [:]))
        state.presentInAppWebViewPage = InAppWebFeature.State(url: .submitQuestionsUrl)
        return .none

      case let .presentGiftCardInputBoxPage(.presented(.activationKeySubmitted(key))):
        state.presentGiftCardInputBoxPage = nil
        state.hapticFeedbackTrigger.toggle()
        giftCardAccessManager.setAccess(key)
        return .none

      case .presentGiftCardInputBoxPage:
        return .none

      case .presentInAppWebViewPage(.presented(.closeButtonTapped)):
        state.presentInAppWebViewPage = nil
        return .none

      case .presentInAppWebViewPage:
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

          Button {
            store.send(.submitQuestionsButtonTapped)
          } label: {
            Label("我想出一題", systemImage: "lightbulb")
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
    .fullScreenCover(
      store: self.store.scope(
        state: \.$presentInAppWebViewPage,
        action: { .presentInAppWebViewPage($0) }
      )
    ) { webViewStore in
      InAppWebView(store: webViewStore)
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
