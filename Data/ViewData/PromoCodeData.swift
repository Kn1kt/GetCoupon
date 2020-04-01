
//
//  Promocode.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 06.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import Foundation

class PromoCodeData {
  
  let coupon: String
  let addingDate: Date?
  let estimatedDate: Date?
  let description: String?
  
  let websiteLink: String
  
  let identifier = UUID()
  
  init(coupon: String,
       addingDate: Date? = nil,
       estimatedDate: Date? = nil,
       description: String? = nil,
       websiteLink: String = "") {
    
    self.coupon = coupon
    self.addingDate = addingDate
    self.estimatedDate = estimatedDate
    self.description = description
    self.websiteLink = websiteLink
  }
  
  /// Bridge for stored data
  convenience init(_ promoCode: PromoCodeStoredData) {
    self.init(coupon: promoCode.coupon,
              addingDate: promoCode.addingDate,
              estimatedDate: promoCode.estimatedDate,
              description: promoCode.promoCodeDescription,
              websiteLink: promoCode.websiteLink)
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
