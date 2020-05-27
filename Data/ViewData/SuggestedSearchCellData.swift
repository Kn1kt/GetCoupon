//
//  SuggestedSearchCellData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 26.05.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class SuggestedSearchCellData {
  
  let tokenText: String
  
  init(tokenText: String) {
    self.tokenText = tokenText
  }
  
  let identifier = UUID()
}

  // MARK: - Hashable
extension SuggestedSearchCellData: Hashable {
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  static func == (lhs: SuggestedSearchCellData, rhs: SuggestedSearchCellData) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}

extension SuggestedSearchCellData: CustomStringConvertible {
  var description: String {
    return tokenText
  }
}
