//
//  RootView.swift
//  check-in-box-ios
//
//  Created by Yi-Chin Hsu on 2023/12/13.
//

import SwiftUI
import Features

struct RootView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Spacer()
                FeatureCardView(title: "經典隨機", subtitle: "Check-in Box")
                    .cornerRadius(16)
            }
            .padding(.horizontal)
            .navigationTitle("Check it out.")
        }
    }
}

#Preview {
    RootView()
        .preferredColorScheme(.dark)
}
