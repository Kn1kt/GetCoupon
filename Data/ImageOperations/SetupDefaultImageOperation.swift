//
//  SetupDefaultImageOperation.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 02.04.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

final class SetupDefaultImageOperation: AsyncOperation {
  
  let category: ShopCategoryData
  
  init(category: ShopCategoryData) {
    self.category = category
    super.init()
  }
  
  override func main() {
    let cache = CacheController()
    guard let stringURL = cache.setDefaultImage(for: category) else {
      state = .finished
      return
    }

    guard let url = URL(string: stringURL),
      category.defaultImage == nil else {
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
      
      if self.category.defaultImage == nil {
        self.category.defaultImage = image
      }
      
      let cache = CacheController()
      cache.cacheDefaultImage(image, for: self.category.categoryName)
    }.resume()
  }
}
