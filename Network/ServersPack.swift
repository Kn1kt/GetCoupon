//
//  ServersPack.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 08.07.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import Foundation

class ServersPack: Decodable {
  
  let defaultServer: ServerData
  
  let contactEmail: String
  let license: String
  let businessCardWebsite: String
  
  // MARK: - Decodable
  enum CodingKeys: CodingKey {
    case defaultServer, contactEmail, iosLicense, businessCardWebsite
  }
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.defaultServer = try container.decode(ServerData.self, forKey: .defaultServer)
    self.contactEmail = try container.decode(String.self, forKey: .contactEmail)
    self.license = try container.decode(String.self, forKey: .iosLicense)
    self.businessCardWebsite = try container.decode(String.self, forKey: .businessCardWebsite)
  }
}
