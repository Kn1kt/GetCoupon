//
//  NetworkAdvertisingCategoryData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 22.06.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import Foundation

class NetworkAdvertisingCategoryData: Codable {
  
  /// Ads gonna be after this section
  let linkedSection: Int
  
  let adsList: [NetworkAdvertisingCellData]
  
  init(linkedSection: Int,
       adsList: [NetworkAdvertisingCellData]) {
    self.linkedSection = linkedSection
    self.adsList = adsList
  }
}
