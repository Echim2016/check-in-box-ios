//
//  Tag.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/25.
//

import Foundation

public struct Tag: Codable, Equatable, Identifiable, Sendable {
  public let id: String
  public let title: String
  public let subtitle: String
  public let order: Int
  public let code: String
  public let isHidden: Bool
  
  public init(
    id: String = "",
    title: String = "",
    subtitle: String = "",
    order: Int = -1,
    code: String = "",
    isHidden: Bool = false
  ) {
    self.id = id
    self.title = title
    self.subtitle = subtitle
    self.order = order
    self.code = code
    self.isHidden = isHidden
  }
}

public extension Tag {
  static func from(_ box: ThemeBox) -> Self {
    Tag(
      id: box.id,
      title: box.title,
      subtitle: box.subtitle,
      order: box.order,
      code: box.code,
      isHidden: box.isHidden
    )
  }
}
