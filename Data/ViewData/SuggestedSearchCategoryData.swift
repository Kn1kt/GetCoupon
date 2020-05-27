//
//  SuggestedSearchCategoryData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 26.05.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class SuggestedSearchCategoryData {
  
  let categoryTitle: String
  let tokens: [SuggestedSearchCellData]
  
  init(title: String = "", tokens: [SuggestedSearchCellData]) {
    self.categoryTitle = title
    self.tokens = tokens
  }
  
  let identifier = UUID()
}

  // MARK: - Hashable
extension SuggestedSearchCategoryData: Hashable {
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  static func == (lhs: SuggestedSearchCategoryData, rhs: SuggestedSearchCategoryData) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}

extension SuggestedSearchCategoryData: CustomStringConvertible {
  var description: String {
    return categoryTitle + ": " + tokens.description
  }
}
