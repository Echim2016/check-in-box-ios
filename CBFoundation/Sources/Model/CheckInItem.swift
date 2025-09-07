//
//  CheckInItem.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/27.
//

import Foundation

public struct CheckInItem: Codable, Hashable {
  public let content: String
  public let subtitle: String?
  public let url: String?
  public let urlIconName: String?

  public init(
    content: String,
    subtitle: String? = nil,
    url: String? = nil,
    urlIconName: String? = nil
  ) {
    self.content = content
    self.subtitle = subtitle
    self.url = url
    self.urlIconName = urlIconName
  }
}

extension CheckInItem: Equatable, Sendable {}

public extension CheckInItem {
  static func from(_ question: Question) -> Self {
    CheckInItem(content: question.question)
  }
}

public extension CheckInItem {
  static func from(_ item: ThemeBoxContentItems.ThemeBoxContentItem) -> Self {
    CheckInItem(content: item.content, subtitle: item.subtitle, url: item.url, urlIconName: item.iconName)
  }
}
