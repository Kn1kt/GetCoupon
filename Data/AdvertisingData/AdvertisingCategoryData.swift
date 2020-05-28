//
//  AdvertisingCategoryData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 28.05.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class AdvertisingCategoryData {

  /// Ads gonna be after this section
  let linkedSection: Int
  
  let adsList: [AdvertisingCellData]
  
  init(linkedSection: Int,
       adsList: [AdvertisingCellData]) {
    self.linkedSection = linkedSection
    self.adsList = adsList
  }
}
