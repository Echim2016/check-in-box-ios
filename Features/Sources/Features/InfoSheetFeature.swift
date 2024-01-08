//
//  InfoSheetFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2024/1/8.
//

import ComposableArchitecture
import SwiftUI

public struct InfoSheetFeature: Reducer {
  public struct State: Equatable {}

  public enum Action: Equatable {
    case mainActionButtonTapped
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .mainActionButtonTapped:
        return .none
      }
    }
  }
}

public struct InfoSheetView: View {
  let store: StoreOf<InfoSheetFeature>

  public var body: some View {
    Text("Info")
  }
}
