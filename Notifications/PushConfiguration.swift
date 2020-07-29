//
//  PushConfiguration.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 29.07.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import Foundation

struct PushConfiguration: Codable {
  
  let userPreferPush: Bool
  
  let deviceToken: String
  
  let favoriteShops: [String]
  
  init?() {
    guard let userPreferPush = UserDefaults.standard.value(forKey: UserDefaultKeys.pushNotifications.rawValue) as? Bool,
      let deviceToken = NotificationProvider.shared.deviceToken else {
        return nil
    }
    
    let favoriteShops = ModelController.shared.favoritesDataController.currentCollectionsByDates
      .flatMap { category in
        category.shops.map { $0.name }
    }
    
    self.userPreferPush = userPreferPush
    self.deviceToken = deviceToken
    self.favoriteShops = favoriteShops
  }
}
