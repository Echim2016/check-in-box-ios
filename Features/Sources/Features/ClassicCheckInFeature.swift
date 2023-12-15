//
//  ClassicCheckInFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/15.
//

import ComposableArchitecture
import SwiftUI

struct ClassicCheckInFeature: Reducer {
  struct State: Equatable {}

  enum Action: Equatable {
    case tap
  }

  var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .tap:
        return .none
      }
    }
  }
}

struct ClassicCheckInView: View {
  let store: StoreOf<ClassicCheckInFeature>
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { _ in
      Text("Classic")
    }
  }
}

#Preview {
  NavigationStack {
    ClassicCheckInView(
      store: Store(
        initialState: ClassicCheckInFeature.State()
      ) {
        ClassicCheckInFeature()
      }
    )
  }
}
