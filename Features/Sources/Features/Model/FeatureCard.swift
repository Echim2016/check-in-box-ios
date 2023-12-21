//
//  FeatureCard.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/21.
//

import ComposableArchitecture
import Foundation

public struct FeatureCard: Equatable, Identifiable {
  public let id: UUID
  public let title: String
  public let subtitle: String

  public static let `default`: IdentifiedArrayOf<FeatureCard> = [
    FeatureCard(id: UUID(), title: "經典模式", subtitle: "Check-in Box"),
  ]
}
