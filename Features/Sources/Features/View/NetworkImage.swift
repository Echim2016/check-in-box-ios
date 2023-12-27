//
//  NetworkImage.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/27.
//

import Kingfisher
import SwiftUI

struct NetworkImage: View {
  let url: URL?
  var body: some View {
    KFImage(url)
      .resizable()
      .aspectRatio(contentMode: .fill)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
