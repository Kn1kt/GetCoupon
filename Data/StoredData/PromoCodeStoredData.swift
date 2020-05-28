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
  @objc dynamic var addingDate: Date! = nil
  @objc dynamic var estimatedDate: Date! = nil
  @objc dynamic var promoCodeDescription: String! = nil
  
  convenience init(coupon: String,
                   addingDate: Date,
                   estimatedDate: Date,
                   description: String) {
    self.init()
    self.coupon = coupon
    self.addingDate = addingDate
    self.estimatedDate = estimatedDate
    self.promoCodeDescription = description
  }
}

  // MARK: - NetworkPromoCodeData Compatible
extension PromoCodeStoredData {
  
  convenience init(_ networkPromoCode: NetworkPromoCodeData) {
    self.init(coupon: networkPromoCode.coupon,
              addingDate: networkPromoCode.addingDate,
              estimatedDate: networkPromoCode.estimatedDate,
              description: networkPromoCode.promoCodeDescription)
  }
}
