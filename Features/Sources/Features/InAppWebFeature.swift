//
//  InAppWebFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2024/1/8.
//

import ComposableArchitecture
import SwiftUI
import WebKit

public struct InAppWebFeature: Reducer {
  public struct State: Equatable {
    var url: URL
  }

  public enum Action: Equatable {
    case closeButtonTapped
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .closeButtonTapped:
        return .none
      }
    }
  }
}

struct InAppWebView: View {
  let store: StoreOf<InAppWebFeature>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack {
        WebView(url: viewStore.url)
          .ignoresSafeArea()
          .toolbar {
            ToolbarItem(placement: .topBarLeading) {
              Button {
                store.send(.closeButtonTapped)
              } label: {
                Image(systemName: "xmark")
              }
            }
          }
      }
    }
  }

  struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context _: Context) -> WKWebView {
      return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context _: Context) {
      let request = URLRequest(url: url)
      webView.load(request)
    }
  }
}
