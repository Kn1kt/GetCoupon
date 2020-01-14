
//
//  Promocode.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 06.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class PromoCodeData: Codable {
    
    let coupon: String
    let addingDate: Date?
    let estimatedDate: Date?
    let description: String?
    let isHot: Bool
    
    let identifier = UUID()
    
    init(coupon: String,
         addingDate: Date? = nil,
         estimatedDate: Date? = nil,
         description: String? = nil,
         isHot: Bool = false) {
        
        self.coupon = coupon
        self.addingDate = addingDate
        self.estimatedDate = estimatedDate
        self.description = description
        self.isHot = isHot
    }
    
    /// Bridge for stored data
    convenience init(_ promoCode: PromoCodeStoredData) {
        self.init(coupon: promoCode.coupon,
                  addingDate: promoCode.addingDate,
                  estimatedDate: promoCode.estimatedDate,
                  description: promoCode.promoCodeDescription,
                  isHot: promoCode.isHot)
    }
}

// MARK: - Hashable
extension PromoCodeData: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: PromoCodeData, rhs: PromoCodeData) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
