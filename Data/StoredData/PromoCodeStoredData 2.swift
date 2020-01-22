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
    @objc dynamic var addingDate: Date?
    @objc dynamic var estimatedDate: Date?
    @objc dynamic var promoCodeDescription: String?
    @objc dynamic var websiteLink: String = ""
    
    convenience init(coupon: String,
                     addingDate: Date? = nil,
                     estimatedDate: Date? = nil,
                     description: String? = nil,
                     websiteLink: String) {
        self.init()
        self.coupon = coupon
        self.addingDate = addingDate
        self.estimatedDate = estimatedDate
        self.promoCodeDescription = description
        self.websiteLink = websiteLink
    }
}

    // MARK: - NetworkPromoCodeData Compatible
extension PromoCodeStoredData {
    
    convenience init(_ networkPromoCode: NetworkPromoCodeData) {
        self.init(coupon: networkPromoCode.coupon,
                  addingDate: networkPromoCode.addingDate,
                  estimatedDate: networkPromoCode.estimatedDate,
                  description: networkPromoCode.promoCodeDescription,
                  websiteLink: networkPromoCode.websiteLink)
    }
}