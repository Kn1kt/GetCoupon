//
//  NetworkShopCategoryData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 14.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class NetworkShopCategoryData: Codable {
    
    let categoryName: String
    
    let tags: [String]
    
    let shops: [NetworkShopData]
    
    init(categoryName: String,
         tags: [String] = [],
         shops: [NetworkShopData] = []) {
        self.categoryName = categoryName
        self.tags = tags
        self.shops = shops
    }
}
