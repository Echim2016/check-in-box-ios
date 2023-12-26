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
    var questions: CycleIterator<Question> = CycleIterator(base: [])
    var imageUrl: URL? = nil
    var displayQuestion: String? = nil
    
    public init(questions: CycleIterator<Question> = CycleIterator(base: []), imageUrl: URL? = nil) {
      self.questions = questions
      self.imageUrl = imageUrl
      self.displayQuestion = questions.current()?.question
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
        state.displayQuestion = state.questions.next()?.question
        return .none
      case .previousButtonTapped:
        state.displayQuestion = state.questions.back()?.question
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
      .background {
        NetworkImage(url: store.state.imageUrl)
          .blur(radius: 1)
          .overlay {
            Color.black.opacity(0.6)
          }
          .ignoresSafeArea()
      }
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
              Question(question: "身上使用最久的東西是什麼？"),
              Question(question: "最喜歡的一部電影？"),
              Question(question: "今年最期待的一件事情？"),
              Question(question: "我不為人知的一個奇怪技"),
              Question(question: "做過最像大人的事情"),
              Question(question: "今年最快樂的回憶"),
              Question(question: "最想再去一次的國家/城市")
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
