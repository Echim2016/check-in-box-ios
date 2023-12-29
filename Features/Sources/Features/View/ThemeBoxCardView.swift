//
//  ThemeBoxCardView.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/26.
//

import Kingfisher
import SwiftUI

public struct ThemeBoxCardView: View {
  let title: String
  let subtitle: String
  let url: URL?

  public init(title: String, subtitle: String, url: URL? = nil) {
    self.title = title
    self.subtitle = subtitle
    self.url = url
  }

  public var body: some View {
    VStack {
      Text(subtitle)
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Text(title)
        .font(.title2)
        .fontWeight(.semibold)
        .foregroundStyle(.primary)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    .background {
      NetworkImage(url: url)
        .blur(radius: 1)
        .overlay(
          Color.black.opacity(0.3)
        )
    }
  }
}
