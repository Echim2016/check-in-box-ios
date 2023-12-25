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
  public let code: String
}
