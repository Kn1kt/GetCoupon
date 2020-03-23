//
//  ShopCategoryStoredData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 11.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import Foundation
import RealmSwift

class ShopCategoryStoredData: Object {
  
  @objc dynamic var categoryName: String = ""
  
  let tags = List<String>()
  
  let shops = List<ShopStoredData>()
  
  convenience init(categoryName: String,
                   shops: [ShopStoredData] = [],
                   tags: [String] = []) {
    self.init()
    self.categoryName = categoryName
    
    self.shops.append(objectsIn: shops)
    
    self.tags.append(objectsIn: tags)
  }
  
  override static func primaryKey() -> String? {
    return "categoryName"
  }
}

// MARK: - NetworkShopCategoryData Compatible
extension ShopCategoryStoredData {
  
  convenience init(_ networkCategory: NetworkShopCategoryData) {
    self.init(categoryName: networkCategory.categoryName,
              shops: networkCategory.shops.map(ShopStoredData.init),
              tags: networkCategory.tags)
  }
}
