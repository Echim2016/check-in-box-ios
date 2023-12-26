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
  }

  public enum Action: Equatable {
    case sendFeedbackButtonTapped
    case redeemGiftCardButtonTapped
    case presentGiftCardInputBoxPage(PresentationAction<InputBoxFeature.Action>)
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.giftCardAccessManager) var giftCardAccessManager

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
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
            ShareLink(item: "分享一個酷 app 給你！") {
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
          Text("echim.hsu")
        } header: {
          Text("作者")
        }
      }
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
