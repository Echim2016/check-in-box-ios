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
  public let subtitle: String?
  public let url: String?
  public let urlIconName: String?

  public init(
    id: String = UUID().uuidString,
    content: String,
    subtitle: String? = nil,
    url: String? = nil,
    urlIconName: String? = nil
  ) {
    self.id = id
    self.content = content
    self.subtitle = subtitle
    self.url = url
    self.urlIconName = urlIconName
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
    CheckInItem(content: item.content, subtitle: item.subtitle, url: item.url, urlIconName: item.iconName)
  }
}
