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
    @PresentationState var alert: AlertState<Action.Alert>?
    var theme: String = ""
    var questions: CycleIterator<CheckInItem> = CycleIterator(base: [])
    var imageUrl: URL? = nil
    var displayQuestion: String? = nil

    public init(
      alert: AlertState<Action.Alert>? = nil,
      theme: String,
      questions: CycleIterator<CheckInItem> = CycleIterator(base: []),
      imageUrl: URL? = nil
    ) {
      self.alert = alert
      self.theme = theme
      self.questions = questions
      self.imageUrl = imageUrl
      self.displayQuestion = questions.current()?.content
    }
  }

  public enum Action: Equatable {
    case alert(PresentationAction<Alert>)
    case urlButtonTapped
    case pickButtonTapped
    case previousButtonTapped
    case trackViewClassicCheckInPageEvent

    public enum Alert {
      case welcomeMessageDoneButtonTapped
    }
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.firebaseTracker) var firebaseTracker

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case .alert(.presented(.welcomeMessageDoneButtonTapped)):
        firebaseTracker.logEvent(
          .clickClassicCheckInPgWelcomeMessageDoneBtn(
            parameters: [
              "theme": state.theme,
            ]
          )
        )
        return .none
        
      case .alert:
        return .none
        
      case .urlButtonTapped:
        guard
          let urlString = state.questions.current()?.url,
          let url = URL(string: urlString)
        else {
          return .none
        }

        firebaseTracker.logEvent(
          .clickClassicCheckInPgUrlBtn(
            parameters: [
              "theme": state.theme,
              "current_content": state.displayQuestion ?? "",
              "url": url.absoluteString,
            ]
          )
        )

        return .run { _ in
          await openURL(url)
        }

      case .pickButtonTapped:
        firebaseTracker.logEvent(
          .clickClassicCheckInPgPickBtn(
            parameters: [
              "theme": state.theme,
              "current_content": state.displayQuestion ?? "",
              "current_index": state.questions.index,
              "items_total_count": state.questions.base.count,
            ]
          )
        )
        state.displayQuestion = state.questions.next()?.content
        return .none

      case .previousButtonTapped:
        firebaseTracker.logEvent(
          .clickClassicCheckInPgPreviousBtn(
            parameters: [
              "theme": state.theme,
              "current_content": state.displayQuestion ?? "",
              "current_index": state.questions.index,
              "items_total_count": state.questions.base.count,
            ]
          )
        )
        state.displayQuestion = state.questions.back()?.content
        return .none
        
      case .trackViewClassicCheckInPageEvent:
        firebaseTracker.logEvent(
          .viewClassicCheckInPg(
            parameters: [
              "theme": state.theme,
            ]
          )
        )
        return .none
      }
    }
    .ifLet(\.$alert, action: /Action.alert)
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
          .animation(
            .easeInOut(duration: 0.25),
            value: store.displayQuestion
          )

        Spacer()
        Spacer()

        HStack {
          Button {
            store.send(.pickButtonTapped)
          } label: {
            Text("🔮 抽一題")
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
               let iconName = item.urlIconName
            {
              if iconName == iconName.uppercased() {
                Image(iconName)
                  .foregroundStyle(.white)
              } else {
                Image(systemName: iconName)
                  .foregroundStyle(.white)
              }
            }
          }
        }
      }
      .alert(
        store: self.store.scope(state: \.$alert, action: { .alert($0) })
      )
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
          theme: "生活",
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
