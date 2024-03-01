//
//  InfoSheetFeature.swift
//
//
//  Created by Yi-Chin Hsu on 2024/1/8.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct InfoSheetFeature {
  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case doneButtonTapped
    case trackViewInfoIntroEvent
  }
  
  @Dependency(\.firebaseTracker) var firebaseTracker

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .doneButtonTapped:
        firebaseTracker.logEvent(.clickInfoIntroPgDoneBtn(parameters: [:]))
        return .none
      case .trackViewInfoIntroEvent:
        firebaseTracker.logEvent(.viewInfoIntroPg(parameters: [:]))
        return .none
      }
    }
  }
}

public struct InfoSheetView: View {
  let store: StoreOf<InfoSheetFeature>

  public var body: some View {
    NavigationStack {
      InfoIntroView()
        .onAppear {
          store.send(.trackViewInfoIntroEvent)
        }
        .toolbar {
          ToolbarItem {
            Button {
              store.send(.doneButtonTapped)
            } label: {
              Text("完成")
                .foregroundStyle(.white)
            }
          }
        }
    }
  }
}

struct InfoIntroView: View {
  @State var selectedPage: Int = 0
  @State var displayQuestion: String = "＊＊＊＊＊＊＊＊＊"
  let questions = CycleIterator(
    base: [
      "近期最期待的事", "最近買過最貴的東西", "我最常光顧的一間餐廳", "最近買的一個小東西",
    ]
  )

  var body: some View {
    TabView(selection: $selectedPage) {
      introItem(
        title: "Check-in 是什麼？",
        content: "Check-in 是一種引人入勝的暖身遊戲，透過特定話題啟動對話，拉近你與夥伴之間更緊密的連結。",
        imageName: "info-talks"
      )
      .tag(1)

      introItem(
        title: "團隊，煥然一新",
        content: "會議之前，來一場 10 分鐘的 Check-in 暖身，啟動工作氛圍，讓每個夥伴都準備好發揮最佳表現。",
        imageName: "info-teambuilding"
      )
      .tag(2)

      introItem(
        title: "聚會，意猶未盡",
        content: "歡聚時刻，和夥伴們用一場精彩萬分的 Check-in 來炒熱氣氛，發現彼此不為人知的另一面！",
        imageName: "info-chat"
      )
      .tag(3)

      introItem(
        title: "一個人，不孤單",
        content: "關注每月主題，與自己共度一場意義非凡的個人 Check-in！\n",
        imageName: "info-self"
      )
      .tag(4)

      howToUseItem(
        title: "如何使用",
        content: "選一個喜歡的話題類別、輕點「抽一題」、展開你與夥伴的專屬對話！"
      )
      .tag(5)

      introItem(
        title: "場景，由你創造",
        content: "在山上、在海邊、在車上、在沙發上... 無論身處何處，現在就開始和身邊的夥伴來一場 Check-in 吧！",
        imageName: "info-party"
      )
      .tag(6)
    }
    .tabViewStyle(.page)
    .indexViewStyle(.page(backgroundDisplayMode: .always))
  }

  @ViewBuilder
  func introItem(
    title: String,
    content: String,
    imageName: String
  ) -> some View {
    VStack(spacing: 40) {
      Text(title)
        .font(.title)
        .bold()

      Image(imageName)
        .resizable()
        .background {
          Color.white
        }
        .clipShape(.rect(cornerRadius: 32))
        .frame(width: 250, height: 250)

      Text(content)
        .font(.body)

      Spacer()
    }
    .padding()
    .padding()
    .frame(height: 550)
  }

  @ViewBuilder
  func howToUseItem(
    title: String,
    content: String
  ) -> some View {
    VStack(spacing: 40) {
      Text(title)
        .font(.title)
        .bold()

      VStack(spacing: 24) {
        Text(displayQuestion)
          .multilineTextAlignment(.center)
          .font(.title2)
          .bold()
          .animation(
            .easeInOut(duration: 0.25),
            value: questions.current()
          )

        Button {
          questions.next()
          displayQuestion = questions.current() ?? ""
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
      .frame(width: 250, height: 250)

      Text(content)
        .font(.body)

      Spacer()
    }
    .padding()
    .padding()
    .frame(height: 550)
  }
}
