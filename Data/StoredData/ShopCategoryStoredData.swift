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
        
        shops.forEach {
            self.shops.append($0)
        }
        
        tags.forEach {
            self.tags.append($0)
        }
    }
    
    override static func primaryKey() -> String? {
        return "categoryName"
    }
}
