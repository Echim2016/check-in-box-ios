//
//  Question.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/21.
//

public struct Question: Identifiable, Codable {
  public let id: String
  public let isHidden: Bool
  public let question: String
}
