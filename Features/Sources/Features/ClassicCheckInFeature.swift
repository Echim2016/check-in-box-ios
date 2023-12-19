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
    var questions: CycleIterator<String> = CycleIterator(base: [])
    var displayQuestion: String? = nil
    
    init(questions: CycleIterator<String> = CycleIterator(base: [])) {
      self.questions = questions
      displayQuestion = questions.base.first
    }
  }

  public enum Action: Equatable {
    case pickButtonTapped
    case previousButtonTapped
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .pickButtonTapped:
        state.displayQuestion = state.questions.next()
        return .none
      case .previousButtonTapped:
        state.displayQuestion = state.questions.back()
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

        Text(store.displayQuestion ?? "")
          .multilineTextAlignment(.center)
          .font(.title)
          .bold()

        Spacer()
        Spacer()

        HStack {
          Button {
            store.send(.previousButtonTapped)
          } label: {
            Text("👋 上一題")
              .font(.headline)
              .foregroundColor(.black)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 16)
              .background(.white)
              .clipShape(RoundedRectangle(cornerRadius: 12.0))
          }
          
          Button {
            store.send(.pickButtonTapped)
          } label: {
            Text("🔮 下一題")
              .font(.headline)
              .foregroundColor(.black)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 16)
              .background(.white)
              .clipShape(RoundedRectangle(cornerRadius: 12.0))
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
          questions: CycleIterator(
            base: [
              "身上使用最久的東西是什麼？",
              "最喜歡的一部電影？",
              "今年最期待的一件事情？",
              "我不為人知的一個奇怪技能",
              "做過最像大人的事情",
              "今年最快樂的回憶",
              "最想再去一次的國家/城市",
            ]
          )
        )
      ) {
        ClassicCheckInFeature()
      }
    )
  }
  .preferredColorScheme(.dark)
}
