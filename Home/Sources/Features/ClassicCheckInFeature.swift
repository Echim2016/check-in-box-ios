//
//  ClassicCheckInFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/15.
//

import CBFoundation
import ComposableArchitecture
import FirebaseService
import SwiftUI

@Reducer
public struct ClassicCheckInFeature {
  @ObservableState
  public struct State: Equatable {
    @Presents var alert: AlertState<Action.Alert>? = nil
    var initialAlertContent: InitialAlertContent?
    var tag: Tag?
    var questions: CycleIterator<CheckInItem>
    var imageUrl: URL?
    var displayQuestion: String?
    var displaySubtitle: String?

    public init(
      initialAlertContent: InitialAlertContent? = nil,
      tag: Tag? = nil,
      questions: CycleIterator<CheckInItem> = CycleIterator(base: []),
      imageUrl: URL? = nil
    ) {
      self.initialAlertContent = initialAlertContent
      self.tag = tag
      self.questions = questions
      self.imageUrl = imageUrl
      displayQuestion = questions.current()?.content
      displaySubtitle = questions.current()?.subtitle
    }
    
    public struct InitialAlertContent: Equatable {
      public var title: String
      public var message: String
    }
  }

  public enum Action: Equatable, BindableAction {
    case alert(PresentationAction<Alert>)
    case binding(BindingAction<State>)
    case onTask
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

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .alert(.presented(.welcomeMessageDoneButtonTapped)):
        firebaseTracker.logEvent(
          .clickClassicCheckInPgWelcomeMessageDoneBtn(
            parameters: [
              "theme": state.tag?.code ?? "",
            ]
          )
        )
        return .none

      case .alert:
        return .none
        
      case .binding:
        return .none
        
      case .onTask:
        if let initialAlertContent = state.initialAlertContent {
          state.alert = AlertState(
            title: {
              TextState(initialAlertContent.title)
            },
            actions: {
              ButtonState(action: .welcomeMessageDoneButtonTapped) {
                TextState("好")
              }
            },
            message: {
              TextState(initialAlertContent.message.replacingOccurrences(of: "\\n", with: "\n"))
            }
          )
        }
        
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
              "theme": state.tag?.code ?? "",
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
              "theme": state.tag?.code ?? "",
              "current_content": state.displayQuestion ?? "",
              "current_index": state.questions.index,
              "items_total_count": state.questions.base.count,
            ]
          )
        )
        state.questions.next()
        state.displayQuestion = state.questions.current()?.content
        state.displaySubtitle = state.questions.current()?.subtitle
        return .none

      case .previousButtonTapped:
        firebaseTracker.logEvent(
          .clickClassicCheckInPgPreviousBtn(
            parameters: [
              "theme": state.tag?.code ?? "",
              "current_content": state.displayQuestion ?? "",
              "current_index": state.questions.index,
              "items_total_count": state.questions.base.count,
            ]
          )
        )
        state.questions.back()
        state.displayQuestion = state.questions.current()?.content
        state.displaySubtitle = state.questions.current()?.subtitle
        return .none

      case .trackViewClassicCheckInPageEvent:
        firebaseTracker.logEvent(
          .viewClassicCheckInPg(
            parameters: [
              "theme": state.tag?.code ?? "",
              "order": state.tag?.order ?? -1,
            ]
          )
        )
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
  }
}

public struct ClassicCheckInView: View {
  @Bindable var store: StoreOf<ClassicCheckInFeature>

  public init(store: StoreOf<ClassicCheckInFeature>) {
    self.store = store
  }

  public var body: some View {
    VStack {
      Spacer()

      VStack(spacing: 32) {
        Text(store.displayQuestion ?? "")
          .multilineTextAlignment(.center)
          .font(.title)
          .bold()
          .animation(
            .easeInOut(duration: 0.25),
            value: store.displayQuestion
          )

        Text(store.displaySubtitle ?? "")
          .multilineTextAlignment(.center)
          .font(.headline)
          .foregroundStyle(.secondary)
          .animation(
            .easeInOut(duration: 0.25),
            value: store.displaySubtitle
          )
      }

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
    .task {
      store.send(.onTask)
    }
    .onAppear {
      store.send(.trackViewClassicCheckInPageEvent)
    }
    .padding()
    .toolbar {
      if let item = store.state.questions.current(),
         let iconImage = item.iconImage
      {
        ToolbarItem {
          Button {
            store.send(.urlButtonTapped)
          } label: {
            iconImage
              .foregroundStyle(.white)
          }
        }
      }
    }
    .alert($store.scope(state: \.alert, action: \.alert))
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

extension CheckInItem {
  var iconImage: Image? {
    guard let iconName = urlIconName, !iconName.isEmpty else {
      return nil
    }
    return iconName == iconName.uppercased()
      ? Image(iconName)
      : Image(systemName: iconName)
  }
}

#Preview {
  NavigationStack {
    ClassicCheckInView(
      store: Store(
        initialState: ClassicCheckInFeature.State(
          questions: CycleIterator(
            base: [
              CheckInItem.from(Question(question: "身上使用最久的東西是什麼？")),
              CheckInItem.from(Question(question: "最喜歡的一部電影？")),
              CheckInItem.from(Question(question: "今年最期待的一件事情？")),
              CheckInItem.from(Question(question: "我不為人知的一個奇怪技")),
              CheckInItem.from(Question(question: "做過最像大人的事情")),
              CheckInItem.from(Question(question: "今年最快樂的回憶")),
              CheckInItem.from(Question(question: "最想再去一次的國家/城市")),
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
