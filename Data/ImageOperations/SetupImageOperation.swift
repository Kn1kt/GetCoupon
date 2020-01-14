//
//  SetupImageOperation.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 13.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

final class SetupImageOperation: AsyncOperation {
    
    let shop: ShopData
    
    init(shop: ShopData) {
        self.shop = shop
        super.init()
    }
    
    override func main() {
        let cache = CacheController()
        guard let stringURL = cache.setImage(for: shop) else {
            state = .finished
            return
        }
        
        guard let url = URL(string: stringURL),
            shop.image == nil else {
                state = .finished
                return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                    let data = data,
                    let image = UIImage(data: data) else {
                return
            }
//            defer { self.state = .finished }
            if self.shop.image == nil {
                self.shop.image = image
            }
            
            let cache = CacheController()
            cache.cacheImage(image, for: self.shop.name)
            self.state = .finished
        }.resume()
    }
}
