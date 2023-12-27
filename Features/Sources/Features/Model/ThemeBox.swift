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
  public let questions: [String]
  public let authorName: String
  public let url: String
  public let imageUrl: String
  public let order: Int
  public let isHidden: Bool
  public let items: ThemeBoxContentItems
}

public struct ThemeBoxContentItems: Equatable, Decodable {
  public let items: [ThemeBoxContentItem]
  
  public struct ThemeBoxContentItem: Equatable, Decodable {
    public let content: String
    public let url: String
    public let order: Int
    public let iconName: String
    
    enum CodingKeys: String, CodingKey {
      case content
      case url
      case order
      case iconName = "icon_name"
    }
  }
}
