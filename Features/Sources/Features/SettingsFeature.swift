//
//  SettingsFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/20.
//

import ComposableArchitecture
import StoreKit
import SwiftUI

@Reducer
public struct SettingsFeature {
  @ObservableState
  public struct State: Equatable {
    @Presents var presentDebugModeInputBoxPage: InputBoxFeature.State?
    @Presents var presentInAppWebViewPage: InAppWebFeature.State?
    var feedbackFormUrl: URL = .feedbackFormUrl
    var authorProfileUrl: URL = .authorProfileUrl
    var authorProfileImageUrl: URL? = .authorProfileImageUrl
    var shareLinkUrl: URL = .shareLinkUrl
    var submitQuestionsUrl: URL = .submitQuestionsUrl
    var debugModeButtonEnabled: Bool = false
  }

  public enum Action: Equatable {
    case authorProfileButtonTapped
    case debugModeButtonEnabled
    case debugModeButtonTapped
    case sendFeedbackButtonTapped
    case shareButtonTapped
    case submitQuestionsButtonTapped
    case submitAppReviewButtonTapped
    case presentDebugModeInputBoxPage(PresentationAction<InputBoxFeature.Action>)
    case presentInAppWebViewPage(PresentationAction<InAppWebFeature.Action>)
    case trackViewSettingsPageEvent
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.debugModeManager) var debugModeManager
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

      case .debugModeButtonEnabled:
        state.debugModeButtonEnabled = true
        return .none

      case .debugModeButtonTapped:
        state.presentDebugModeInputBoxPage = InputBoxFeature.State()
        return .none

      case .shareButtonTapped:
        firebaseTracker.logEvent(.clickSettingsPgShareBtn(parameters: [:]))
        return .none

      case .sendFeedbackButtonTapped:
        firebaseTracker.logEvent(.clickSettingsPgFeedbackFormBtn(parameters: [:]))
        state.presentInAppWebViewPage = InAppWebFeature.State(url: .feedbackFormUrl)
        return .none

      case .submitQuestionsButtonTapped:
        firebaseTracker.logEvent(.clickSettingsPgSubmitQuestionsBtn(parameters: [:]))
        state.presentInAppWebViewPage = InAppWebFeature.State(url: .submitQuestionsUrl)
        return .none

      case .submitAppReviewButtonTapped:
        firebaseTracker.logEvent(.clickSettingsPgSubmitAppReviewBtn(parameters: [:]))
        return .none

      case let .presentDebugModeInputBoxPage(.presented(.activationKeySubmitted(key))):
        state.presentDebugModeInputBoxPage = nil
        debugModeManager.setAccess(key)
        return .none

      case .presentDebugModeInputBoxPage:
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
    .ifLet(\.$presentDebugModeInputBoxPage, action: \.presentDebugModeInputBoxPage) {
      InputBoxFeature()
    }
  }
}

struct SettingsView: View {
  let store: StoreOf<SettingsFeature>
  @Environment(\.requestReview) var requestReview

  var body: some View {
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

        Button {
          store.send(.submitAppReviewButtonTapped)
          requestReview()
        } label: {
          Label("評價五顆星", systemImage: "star")
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

      if store.debugModeButtonEnabled {
        Section {
          Button {
            store.send(.debugModeButtonTapped)
          } label: {
            Label("Debug Mode", systemImage: "wrench.adjustable")
              .foregroundStyle(.white)
          }
        } header: {
          Text("Debug")
        }
      }

      if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
         let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
      {
        Section {
          Text("v\(version) (\(buildNumber))")
            .foregroundStyle(.secondary)
            .onTapGesture(count: 10) {
              store.send(.debugModeButtonEnabled)
            }
        } header: {
          Text("版本")
        }
      }
    }
    .onAppear {
      store.send(.trackViewSettingsPageEvent)
    }
    .sheet(
      store: self.store.scope(
        state: \.$presentDebugModeInputBoxPage,
        action: \.presentDebugModeInputBoxPage
      )
    ) { inputBoxViewStore in
      InputBoxView(store: inputBoxViewStore)
        .presentationDetents([.height(180)])
    }
    .fullScreenCover(
      store: self.store.scope(
        state: \.$presentInAppWebViewPage,
        action: \.presentInAppWebViewPage
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
