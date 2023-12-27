//
//  CheckInItem.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/27.
//

import Foundation

public struct CheckInItem: Identifiable, Codable {
  public let id: String
  public let content: String
  public let url: String?

  public init(
    id: String = UUID().uuidString,
    content: String,
    url: String? = nil
  ) {
    self.id = id
    self.content = content
    self.url = url
  }
}

extension CheckInItem: Equatable, Sendable {}

extension CheckInItem {
  static func from(_ question: Question) -> Self {
    CheckInItem(id: question.id, content: question.question)
  }
}

extension CheckInItem {
  static func from(_ item: ThemeBoxContentItems.ThemeBoxContentItem) -> Self {
    CheckInItem(content: item.content, url: item.url)
  }
}
