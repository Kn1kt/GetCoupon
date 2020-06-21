//
//  AdvertisingCellData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 28.05.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AdvertisingCellData {
  
  let imageLink: String
  let websiteLink: String
  /// Define ads place
  let priority: Int
  
  let image = BehaviorRelay<UIImage?>(value: nil)
  
  init(imageLink: String,
       websiteLink: String,
       priority: Int) {
    self.imageLink = imageLink
    self.websiteLink = websiteLink
    self.priority = priority
  }
}
