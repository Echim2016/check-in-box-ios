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
    getMockThemeBox()
      .items
      .items
      .map(CheckInItem.from)
  }

  func getMockTags() -> [Tag] {
    [
      Tag(id: "1", title: "Deep", subtitle: "", order: 1, code: "deep", isHidden: false),
    ]
  }
  
  func getMockThemeBox() -> ThemeBox {
    ThemeBox(
      id: "1",
      title: "主題盒子標題",
      subtitle: "主題盒子副標題",
      code: "test",
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
            iconName: "globe"
          ),
          ThemeBoxContentItems.ThemeBoxContentItem(
            content: "內容2",
            subtitle: "副標題2",
            url: "",
            order: 2,
            iconName: "globe"
          ),
          ThemeBoxContentItems.ThemeBoxContentItem(
            content: "內容3",
            subtitle: "副標題3",
            url: "",
            order: 3,
            iconName: "globe"
          ),
        ]
      )
    )
  }
  
  func getMockThemeBox(withSameItemOrder order: Int) -> ThemeBox {
    ThemeBox(
      id: "1",
      title: "主題盒子標題",
      subtitle: "主題盒子副標題",
      code: "test",
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
            order: order,
            iconName: "globe"
          ),
          ThemeBoxContentItems.ThemeBoxContentItem(
            content: "內容2",
            subtitle: "副標題2",
            url: "",
            order: order,
            iconName: "globe"
          ),
        ]
      )
    )
  }

  func getMockThemeBoxes() -> [ThemeBox] {
    [getMockThemeBox()]
  }
}
