//
//  ClassicCheckInFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/15.
//

import ComposableArchitecture
import SwiftUI

public struct ClassicCheckInFeature: Reducer {
  public struct State: Equatable {
    var questions: [String] = []
  }

  public enum Action: Equatable {
    case pickButtonTapped
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .pickButtonTapped:
        // TODO: Performance improvement
        state.questions = state.questions.shuffled()
        return .none
      }
    }
  }
}

struct ClassicCheckInView: View {
  let store: StoreOf<ClassicCheckInFeature>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { store in
      VStack {
        Spacer()
        
        Text(store.questions.first ?? "")
          .multilineTextAlignment(.center)
          .font(.title)
          .bold()
        
        Spacer()

        VStack {
          Button {
            store.send(.pickButtonTapped)
          } label: {
            Label("換一題", systemImage: "arrow.counterclockwise")
              .font(.headline)
              .foregroundColor(.black)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 16)
              .background(.white)
              .clipShape(Capsule())
          }
        }
      }
      .padding()
    }
  }
}

#Preview {
  NavigationStack {
    ClassicCheckInView(
      store: Store(
        initialState: ClassicCheckInFeature.State(
          questions: [
            "身上使用最久的東西是什麼？",
            "最喜歡的一部電影？",
            "今年最期待的一件事情？",
            "我不為人知的一個奇怪技能",
            "做過最像大人的事情",
            "今年最快樂的回憶",
            "最想再去一次的國家/城市",
          ]
        )
      ) {
        ClassicCheckInFeature()
      }
    )
  }
  .preferredColorScheme(.dark)
}
