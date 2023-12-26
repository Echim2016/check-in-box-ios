//
//  InputBoxFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/26.
//

import ComposableArchitecture
import SwiftUI

public struct InputBoxFeature: Reducer {
  public struct State: Equatable {
    var activationKey: String = ""
  }

  public enum Action: Equatable {
    case activateButtonTapped
    case activationKeySubmitted(String)
    case keyChanged(String)
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .activateButtonTapped:
        if state.activationKey.isEmpty {
          return .none
        } else {
          return .send(.activationKeySubmitted(state.activationKey))
        }
      case .activationKeySubmitted:
        return .none
      case let .keyChanged(key):
        state.activationKey = key
        return .none
      }
    }
  }
}

struct InputBoxView: View {
  let store: StoreOf<InputBoxFeature>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { store in
      VStack {
        TextField(
          "請輸入禮物卡序號",
          text: store.binding(
            get: { $0.activationKey },
            send: { .keyChanged($0) }
          )
        )
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .textFieldStyle(CBTextFieldStyle())
        .tint(.white)
        .frame(height: 60)

        Button {
          store.send(.activateButtonTapped)
        } label: {
          Text("兌換")
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
        }
      }
      .padding(.top, 44)
    }
  }
}

struct CBTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<Self._Label>) -> some View {
    configuration
      .padding()
      .background(
        RoundedRectangle(
          cornerRadius: 12,
          style: .continuous
        )
        .fill(.white.opacity(0.15))
      )
      .padding()
  }
}
