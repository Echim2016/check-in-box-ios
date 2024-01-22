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
