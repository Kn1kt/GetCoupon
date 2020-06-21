//
//  NetworkAdvertisingCellData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 22.06.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import Foundation

class NetworkAdvertisingCellData: Codable {
  
  let imageLink: String
  let websiteLink: String
  /// Define ads place
  let priority: Int
  
  init(imageLink: String,
       websiteLink: String,
       priority: Int) {
    self.imageLink = imageLink
    self.websiteLink = websiteLink
    self.priority = priority
  }
}
