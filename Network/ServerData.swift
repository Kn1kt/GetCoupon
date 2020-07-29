//
//  ServerData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 08.07.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import Foundation

class ServerData: Decodable {
  
  let baseServerLink: String
  let database: String
  let adv: String
  
  let feedbackCouponLink = "/add-promocode"
  let feedbackGeneralLink = "/add-feedback"
  let pushConfigurationLink = ""
  
  init(baseServerLink: String,
       database: String,
       adv: String) {
    self.baseServerLink = baseServerLink
    self.database = database
    self.adv = adv
  }
  
  // MARK: - Decodable
  enum CodingKeys: CodingKey {
    case serverAddress, iosJson, iosAds
  }
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.baseServerLink = try container.decode(String.self, forKey: .serverAddress)
    self.database = try container.decode(String.self, forKey: .iosJson)
    self.adv = try container.decode(String.self, forKey: .iosAds)
  }
}

