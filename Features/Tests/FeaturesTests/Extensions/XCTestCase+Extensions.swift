//
//  XCTestCase+Extensions.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/21.
//

import XCTest
@testable import Features

extension XCTestCase {
  func getMockMultipleQuestions() -> [Question] {
    [
      Question(question: "身上使用最久的東西是什麼？"),
      Question(question: "最喜歡的一部電影？"),
      Question(question: "今年最期待的一件事情？"),
      Question(question: "我不為人知的一個奇怪技"),
      Question(question: "做過最像大人的事情"),
      Question(question: "今年最快樂的回憶"),
      Question(question: "最想再去一次的國家/城市")
    ]
  }
  
  func getMockTags() -> [Tag] {
    [
      Tag(id: "1", title: "Deep", subtitle: "", code: "deep"),
    ]
  }
}
