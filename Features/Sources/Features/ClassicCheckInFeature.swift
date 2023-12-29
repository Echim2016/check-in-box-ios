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
    var questions: CycleIterator<CheckInItem> = CycleIterator(base: [])
    var imageUrl: URL? = nil
    var displayQuestion: String? = nil
    
    public init(questions: CycleIterator<CheckInItem> = CycleIterator(base: []), imageUrl: URL? = nil) {
      self.questions = questions
      self.imageUrl = imageUrl
      self.displayQuestion = questions.current()?.content
    }
  }

  public enum Action: Equatable {
    case urlButtonTapped
    case pickButtonTapped
    case previousButtonTapped
    case trackViewClassicCheckInPageEvent
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.firebaseTracker) var firebaseTracker

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .urlButtonTapped:
        guard
          let urlString = state.questions.current()?.url,
          let url = URL(string: urlString)
        else {
          return .none
        }

        return .run { _ in
          await openURL(url)
        }
        
      case .pickButtonTapped:
        state.displayQuestion = state.questions.next()?.content
        return .none
        
      case .previousButtonTapped:
        state.displayQuestion = state.questions.back()?.content
        return .none
        
      case .trackViewClassicCheckInPageEvent:
        firebaseTracker.logEvent(.viewClassicCheckInPg(parameters: [:]))
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
      .onAppear {
        store.send(.trackViewClassicCheckInPageEvent)
      }
      .padding()
      .toolbar {
        ToolbarItem {
          Button {
            store.send(.urlButtonTapped)
          } label: {
            if let item = store.state.questions.current(),
               let iconName = item.urlIconName {
              Image(iconName)
                .foregroundStyle(.white)
            }
          }
        }
      }
      .background {
        NetworkImage(url: store.state.imageUrl)
          .blur(radius: 2)
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
              .from(Question(question: "身上使用最久的東西是什麼？")),
              .from(Question(question: "最喜歡的一部電影？")),
              .from(Question(question: "今年最期待的一件事情？")),
              .from(Question(question: "我不為人知的一個奇怪技")),
              .from(Question(question: "做過最像大人的事情")),
              .from(Question(question: "今年最快樂的回憶")),
              .from(Question(question: "最想再去一次的國家/城市")),
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
