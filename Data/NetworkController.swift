//
//  NetworkController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 12.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class NetworkController {
    
    static func downloadImage(url: String, shop: ShopData) {
        
        guard let url = URL(string: url),
            shop.image == nil else {
                return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let image = UIImage(data: data) else {
              return
            }
            
            if shop.image == nil {
                shop.image = image
            }
            
            let cache = CacheController()
            cache.cacheImage(image, for: shop.name)
        }.resume()
    }
    
    static func downloadPreviewImage(url: String, shop: ShopData) {
        
        guard let url = URL(string: url),
            shop.previewImage == nil else {
                return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let image = UIImage(data: data) else {
              return
            }
            
            if shop.previewImage == nil {
                shop.previewImage = image
            }
            
            let cache = CacheController()
            cache.cacheImage(image, for: shop.name)
        }.resume()
    }
}
