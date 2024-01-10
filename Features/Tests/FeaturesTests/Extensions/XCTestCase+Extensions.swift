//
//  XCTestCase+Extensions.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/21.
//

@testable import Features
import XCTest

extension XCTestCase {
  func getMockMultipleQuestions() -> [Question] {
    [
      Question(question: "身上使用最久的東西是什麼？"),
      Question(question: "最喜歡的一部電影？"),
      Question(question: "今年最期待的一件事情？"),
      Question(question: "我不為人知的一個奇怪技"),
      Question(question: "做過最像大人的事情"),
      Question(question: "今年最快樂的回憶"),
      Question(question: "最想再去一次的國家/城市"),
    ]
  }
  
  func getMockMultipleCheckInItems() -> [CheckInItem] {
    getMockMultipleQuestions()
      .map(CheckInItem.from)
  }

  func getMockTags() -> [Tag] {
    [
      Tag(id: "1", title: "Deep", subtitle: "", order: 1, code: "deep", isHidden: false),
    ]
  }

  func getMockThemeBoxes() -> [ThemeBox] {
    [
      ThemeBox(
        id: "1",
        title: "主題盒子標題",
        subtitle: "主題盒子副標題",
        alertTitle: "",
        alertMessage: "",
        authorName: "echim",
        url: "",
        imageUrl: "",
        order: 1,
        isHidden: true,
        items: ThemeBoxContentItems(
          items: [
            ThemeBoxContentItems.ThemeBoxContentItem(
              content: "內容1",
              subtitle: "副標題1",
              url: "",
              order: 1,
              iconName: "threads"
            ),
            ThemeBoxContentItems.ThemeBoxContentItem(
              content: "內容2",
              subtitle: "副標題1",
              url: "",
              order: 2,
              iconName: "threads"
            ),
          ]
        )
      ),
    ]
  }
}
