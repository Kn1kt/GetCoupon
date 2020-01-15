//
//  NetworkPromoCodeData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 14.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class NetworkPromoCodeData: Codable {
    
    let coupon: String
    let addingDate: Date?
    let estimatedDate: Date?
    let promoCodeDescription: String?
    
    let websiteLink: String
    
    init(coupon: String,
         addingDate: Date? = nil,
         estimatedDate: Date? = nil,
         promoCodeDescription: String? = nil,
         websiteLink: String) {
        
        self.coupon = coupon
        self.addingDate = addingDate
        self.estimatedDate = estimatedDate
        self.promoCodeDescription = promoCodeDescription
        self.websiteLink = websiteLink
    }
}

    // MARK: - Hashable
extension NetworkPromoCodeData: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(addingDate)
        hasher.combine(estimatedDate)
    }

    static func == (lhs: NetworkPromoCodeData, rhs: NetworkPromoCodeData) -> Bool {
        return lhs.coupon == rhs.coupon
    }
}
