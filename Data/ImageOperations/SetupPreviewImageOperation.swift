//
//  SetupPreviewImageOperation.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 13.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

final class SetupPreviewImageOperation: AsyncOperation {
  
  let shop: ShopData
  
  init(shop: ShopData) {
    self.shop = shop
    super.init()
  }
  
  override func main() {
    let cache = CacheController()
    guard let stringURL = cache.setPreviewImage(for: shop) else {
      state = .finished
      return
    }
    
    guard let link = stringURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
          let url = URL(string: link),
          shop.previewImage == nil else {
        state = .finished
        return
    }
    
    URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
      defer { self?.state = .finished }
      
      guard let self = self,
        let data = data,
        let image = UIImage(data: data) else {
          return
      }
      if self.shop.previewImage == nil {
        self.shop.previewImage = image
      }
      
      let cache = CacheController()
      cache.cachePreviewImage(image, for: self.shop.name)
    }.resume()
  }
}
