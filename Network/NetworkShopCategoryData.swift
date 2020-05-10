//
//  NetworkShopCategoryData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 14.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import Foundation

class NetworkShopCategoryData: Codable {
  
  let categoryName: String
  let defaultImageLink: String
  let priority: Int
  
  let tags: [String]
  
  let shops: [NetworkShopData]
  
  init(categoryName: String,
       defaultImageLink: String,
       priority: Int,
       tags: [String] = [],
       shops: [NetworkShopData] = []) {
    self.categoryName = categoryName
    self.defaultImageLink = defaultImageLink
    self.priority = priority
    self.tags = tags
    self.shops = shops
  }
}
