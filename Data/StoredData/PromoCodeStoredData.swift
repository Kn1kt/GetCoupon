//
//  PromoCodeStoredData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 11.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import Foundation
import RealmSwift

class PromoCodeStoredData: Object {
    
    @objc dynamic var coupon: String = ""
    @objc dynamic var addingDate: Date? = nil
    @objc dynamic var estimatedDate: Date? = nil
    @objc dynamic var promoCodeDescription: String? = nil
    @objc dynamic var isHot: Bool = false
    
    convenience init(coupon: String,
                     addingDate: Date? = nil,
                     estimatedDate: Date? = nil,
                     description: String? = nil,
                     isHot: Bool = false) {
        self.init()
        self.coupon = coupon
        self.addingDate = addingDate
        self.estimatedDate = estimatedDate
        self.promoCodeDescription = description
        self.isHot = isHot
    }
}
