//
//  InputBoxFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct InputBoxFeature {
  @ObservableState
  public struct State: Equatable {
    var placeholderText: String = "請輸入驗證碼"
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
  @Bindable var store: StoreOf<InputBoxFeature>

  init(store: StoreOf<InputBoxFeature>) {
    self.store = store
  }

  var body: some View {
      VStack(spacing: 12) {
        SecureField(
          store.placeholderText,
          text: $store.activationKey.sending(\.keyChanged)
        )
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .textFieldStyle(CBTextFieldStyle())
        .tint(.white)
        .frame(height: 60)

        Button {
          store.send(.activateButtonTapped)
        } label: {
          Text("確認")
            .font(.headline)
            .foregroundColor(store.activationKey.isEmpty ? .secondary : .black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(store.activationKey.isEmpty ? .white.opacity(0.15) : .white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(store.activationKey.isEmpty)
      }
      .padding(.horizontal)
      .padding(.top)
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
  }
}
