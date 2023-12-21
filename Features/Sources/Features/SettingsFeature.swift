//
//  SettingsFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/20.
//

import ComposableArchitecture
import SwiftUI

public struct SettingsFeature: Reducer {
  public struct State: Equatable {}
  public enum Action: Equatable {
    case sendFeedbackButtonTapped
  }

  @Dependency(\.openURL) var openURL

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .sendFeedbackButtonTapped:
        return .run { send in
          let url = URL(string: "https://forms.gle/Vr4MjtowWPxBxr5r9")!
          await openURL(url)
        }
      }
    }
  }
}

struct SettingsView: View {
  let store: StoreOf<SettingsFeature>
  var body: some View {
    List {
      Section {
        // TODO: app store url & app icon image
        Button {
          
        } label: {
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
