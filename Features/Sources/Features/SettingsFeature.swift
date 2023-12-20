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
  public enum Action: Equatable {}

  public var body: some ReducerOf<Self> {
    Reduce { _, _ in
      .none
    }
  }
}

struct SettingsView: View {
  let store: StoreOf<SettingsFeature>
  var body: some View {
    List {
      Section {
        // TODO: app store url & app icon image
        ShareLink(item: "分享一個酷 app 給你！") {
          Label("分享給朋友", systemImage: "square.and.arrow.up")
            .foregroundStyle(.white)
        }
        
        // TODO: redeem view
        Button {
          
        } label: {
          Label("兌換禮物卡", systemImage: "giftcard")
            .foregroundStyle(.white)
        }
        
        // TODO: feedback form
        Button {
          
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
