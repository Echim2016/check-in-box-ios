//
//  FeatureCardView.swift
//  
//
//  Created by Yi-Chin Hsu on 2023/12/13.
//

import SwiftUI

public struct FeatureCardView: View {
    let title: String
    let subtitle: String
    
    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .padding(.top, 120)
        .background(
            Color.white
                .opacity(0.15)
                .gradient
        )
    }
}

