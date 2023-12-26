//
//  ThemeBox.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/26.
//

import Foundation

public struct ThemeBox: Equatable, Identifiable {
  public let id: UUID
  public let title: String
  public let subtitle: String
  public let questions: [String]
  public let authorName: String
  public let url: String
  public let imageUrl: String
}
