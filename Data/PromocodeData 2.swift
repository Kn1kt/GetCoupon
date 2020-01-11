
//
//  Promocode.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 06.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class PromocodeData: Codable {
    
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
}

// MARK: - Hashable
extension PromocodeData: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: PromocodeData, rhs: PromocodeData) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
