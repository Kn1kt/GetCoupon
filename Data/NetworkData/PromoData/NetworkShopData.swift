//
//  NetworkShopData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 14.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class NetworkShopData: Codable {
  
  let name: String
  let shopDescription: String?
  let shopShortDescription: String
  let priority: Int
  
  let websiteLink: String
  let imageLink: String
  let previewImageLink: String
  
  let placeholderColor: [Float]
  
  let promoCodes: [NetworkPromoCodeData]
  
  let tags: [String]
  
  init(name: String,
       shopDescription: String? = nil,
       shopShortDescription: String,
       priority: Int,
       websiteLink: String,
       imageLink: String,
       previewImageLink: String,
       placeholderColor: [Float] = [],
       promoCodes: [NetworkPromoCodeData] = [],
       tags: [String]) {
    
    self.name = name
    self.shopDescription = shopDescription
    self.shopShortDescription = shopShortDescription
    self.priority = priority
    self.websiteLink = websiteLink
    self.imageLink = imageLink
    self.previewImageLink = previewImageLink
    self.placeholderColor = placeholderColor
    self.promoCodes = promoCodes
    self.tags = tags
  }
}
