//
//  NetworkController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 12.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import Network

class NetworkController {
    
    static func downloadDataBase() {
        DispatchQueue.global(qos: .userInitiated).async {
            let queue = DispatchQueue(label: "monitor")
            let monitor = NWPathMonitor()
            monitor.start(queue: queue)
            
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 1) {
                guard monitor.currentPath.status == .satisfied,
                    let url = URL(string: "https://www.dropbox.com/s/qge216pbfilhy08/collections.json?dl=1") else {
//                let url = URL(string: "http://192.168.0.101:8000") else {
                        ModelController.loadCollectionsFromStorage()
                        return
                }
                
                monitor.cancel()
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data else { return }
                    
                    do {
                        let jsonDecoder = JSONDecoder()
                        let decodedCollections = try jsonDecoder.decode([ShopCategoryStoredData].self, from: data)
                        
                        DispatchQueue.global(qos: .userInitiated).async {
                            let cache = CacheController()
                            cache.updateData(with: decodedCollections)
                            ModelController.loadCollectionsFromStorage()
                        }
                        
                    } catch {
                        debugPrint(error)
                    }
                }.resume()
            }
        }
    }
    
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
            cache.cachePreviewImage(image, for: shop.name)
        }.resume()
    }
}
