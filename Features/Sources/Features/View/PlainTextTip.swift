//
//  PlainTextTip.swift
//
//
//  Created by Yi-Chin Hsu on 2024/1/9.
//

import TipKit

struct PlainTextTip: Tip {
  let tipTitle: String
  let tipMessage: String?

  init(title: String, message: String? = nil) {
    self.tipTitle = title
    self.tipMessage = message
  }

  @Parameter static var isChecked: Bool = false
  
  var rules: [Rule] {
    #Rule(Self.$isChecked) { $0 == false }
  }

  var title: Text {
    Text(tipTitle)
  }

  var message: Text? {
    if let tipMessage {
      Text(tipMessage)
    } else {
      nil
    }
  }
}
