//
//  ShopCategoryData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 09.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ShopCategoryData {
    
    let name: String
    
    let tags: [String]
    
    var shops: [ShopData]
    
    let identifier = UUID()
    
    init(name: String, shops: [ShopData] = [], tags: [String] = []) {
        self.name = name
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
