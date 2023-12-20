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
        Text("echim.hsu")
      } header: {
        Text("作者")
      }
    }
  }
}
