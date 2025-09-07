//
//  ProfileCellView.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/27.
//

import SwiftUI

struct ProfileCellView: View {
  let url: URL?
  var body: some View {
    HStack(spacing: 12) {
      
      NetworkImage(url: url)
        .opacity(0.8)
        .frame(width: 40, height: 40)
        .clipShape(.rect(cornerRadius: 8))
      
      VStack(alignment: .leading) {
        Text("echim hsu")
          .font(.body)
          .fontWeight(.bold)
          .foregroundStyle(.white)
        
        Text("@echim2021")
          .font(.subheadline)
          .foregroundStyle(.white)
      }
    }
  }
}
