//
//  LocalizationProvider.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 07.07.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class LocalizationProvider {
  
  static let shared = LocalizationProvider()
  
  func provideCouponPluralForm(for digit: UInt) -> String {
    let string = NSLocalizedString("coupons_count", comment: "%d coupons count")
    
    return providePluralForm(of: string, for: digit)
  }
  
  func provideShopPluralForm(for digit: UInt) -> String {
    let string = NSLocalizedString("shops_count", comment: "%d shops count")
    
    return providePluralForm(of: string, for: digit)
  }
  
  private func providePluralForm(of string: String, for digit: UInt) -> String {
    return String.localizedStringWithFormat(string, digit)
  }
}

  // MARK: - English support
extension LocalizationProvider {
  
}

  // MARK: - Russian support
extension LocalizationProvider {
  
}
