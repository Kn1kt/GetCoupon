//
//  ShopCategoryData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 09.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ShopCategoryData {
  
  let categoryName: String
  
  let tags: [String]
  
  var shops: [ShopData]
  
  let identifier = UUID()
  
  private var _defaultImage: UIImage? = nil
  private let defaultImageQueue = DispatchQueue(label: "defaultImageQueue", attributes: .concurrent)
  var defaultImage: UIImage? {
    get {
      defaultImageQueue.sync {
        return _defaultImage
      }
    }
    
    set {
      defaultImageQueue.async(flags: .barrier) { [weak self] in
        self?._defaultImage = newValue
      }
    }
  }
  
  init(categoryName: String, shops: [ShopData] = [], tags: [String] = []) {
    self.categoryName = categoryName
    self.shops = shops
    self.tags = tags
  }
  
  /// Bridge for stored data
  convenience init(_ category: ShopCategoryStoredData) {
    let tags = Array(category.tags)
    self.init(categoryName: category.categoryName,
              tags: tags)
    
    let shops = Array(category.shops).map { ShopData($0, category: self) }
    self.shops = shops
  }
}

  // MARK: - Hashable
extension ShopCategoryData: Hashable {
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  static func == (lhs: ShopCategoryData, rhs: ShopCategoryData) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}
