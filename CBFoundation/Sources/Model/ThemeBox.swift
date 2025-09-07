//
//  ThemeBox.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/26.
//

import Foundation

public struct ThemeBox: Equatable, Identifiable, Decodable {
  public let id: String
  public let title: String
  public let subtitle: String
  public let code: String
  public let alertTitle: String
  public let alertMessage: String
  public let authorName: String
  public let url: String
  public let imageUrl: String
  public let order: Int
  public let isHidden: Bool
  public let items: ThemeBoxContentItems
  
  public init(
    id: String,
    title: String,
    subtitle: String,
    code: String,
    alertTitle: String,
    alertMessage: String,
    authorName: String,
    url: String,
    imageUrl: String,
    order: Int,
    isHidden: Bool,
    items: ThemeBoxContentItems
  ) {
    self.id = id
    self.title = title
    self.subtitle = subtitle
    self.code = code
    self.alertTitle = alertTitle
    self.alertMessage = alertMessage
    self.authorName = authorName
    self.url = url
    self.imageUrl = imageUrl
    self.order = order
    self.isHidden = isHidden
    self.items = items
  }
  
  enum CodingKeys: String, CodingKey {
    case id
    case title
    case subtitle
    case code
    case alertTitle = "alert_title"
    case alertMessage = "alert_message"
    case authorName
    case url
    case imageUrl
    case order
    case isHidden
    case items
  }
}

public struct ThemeBoxContentItems: Equatable, Decodable {
  public let items: [ThemeBoxContentItem]
  
  public struct ThemeBoxContentItem: Equatable, Decodable {
    public let content: String
    public let subtitle: String?
    public let url: String?
    public let order: Int
    public let iconName: String?
    
    enum CodingKeys: String, CodingKey {
      case content
      case subtitle
      case url
      case order
      case iconName = "icon_name"
    }
  }
}
