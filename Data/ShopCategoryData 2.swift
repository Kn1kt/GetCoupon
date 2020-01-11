//
//  ShopCategoryData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 09.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ShopCategoryData: Codable {
    
    let categoryName: String
    
    let tags: [String]
    
    var shops: [ShopData]
    
    let identifier = UUID()
    
    init(categoryName: String, shops: [ShopData] = [], tags: [String] = []) {
        self.categoryName = categoryName
        self.shops = shops
        self.tags = tags
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
