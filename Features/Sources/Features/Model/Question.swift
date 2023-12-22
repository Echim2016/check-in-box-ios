//
//  Question.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/21.
//

import Foundation

public struct Question: Identifiable, Codable {
  public let id: String
  public let isHidden: Bool
  public let question: String
  public let tags: [String]
  
  init(
    id: String = UUID().uuidString,
    isHidden: Bool = false,
    question: String,
    tags: [String] = []
  ) {
    self.id = id
    self.isHidden = isHidden
    self.question = question
    self.tags = tags
  }
}

extension Question: Equatable, Sendable {}
