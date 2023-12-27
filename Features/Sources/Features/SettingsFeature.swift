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
    var authorProfileUrl: URL? = URL(string: "https://pbs.twimg.com/profile_images/1473910380540088321/Cw9ziBcy_400x400.jpg")
    var shareLinkContent: String = "https://portaly.cc/check-in-box"
    var hapticFeedbackTrigger: Bool = false
  }

  public enum Action: Equatable {
    case authorProfileButtonTapped
    case sendFeedbackButtonTapped
    case redeemGiftCardButtonTapped
    case presentGiftCardInputBoxPage(PresentationAction<InputBoxFeature.Action>)
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.giftCardAccessManager) var giftCardAccessManager

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .authorProfileButtonTapped:
        return .run { _ in
          let url = URL(string: "https://twitter.com/echim2021")!
          await openURL(url)
        }
        
      case .sendFeedbackButtonTapped:
        return .run { _ in
          let url = URL(string: "https://forms.gle/Vr4MjtowWPxBxr5r9")!
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
          // TODO: app store url & app icon image
          Button {} label: {
            ShareLink(item: store.state.shareLinkContent) {
              /// Problem: Slow loading issue after tapping the share link without any UI indication
              /// Solution: Implement wide label for better pressed state indication
              HStack {
                Label("分享給朋友", systemImage: "square.and.arrow.up")
                  .foregroundStyle(.white)
                Spacer()
                  .frame(minWidth: .leastNonzeroMagnitude)
              }
            }
          }

          // TODO: redeem view
          Button {
            store.send(.redeemGiftCardButtonTapped)
          } label: {
            Label("兌換禮物卡", systemImage: "giftcard")
              .foregroundStyle(.white)
          }

          // TODO: feedback form
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
            ProfileCellView(url: store.state.authorProfileUrl)
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
