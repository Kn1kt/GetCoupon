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
    
    /// Image processing queue
    private static let queue = OperationQueue()
    
    static func downloadDataBase() {
        DispatchQueue.global(qos: .userInitiated).async {
            let queue = DispatchQueue(label: "monitor")
            let monitor = NWPathMonitor()
            monitor.start(queue: queue)
            
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 1) {
                guard monitor.currentPath.status == .satisfied,
                    let url = URL(string: "https://www.dropbox.com/s/qge216pbfilhy08/collections.json?dl=1") else {
                        ModelController.loadCollectionsFromStorage()
                        return
                }
                
                monitor.cancel()
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data else { return }
                    
                    do {
                        let jsonDecoder = JSONDecoder()
                        let decodedCollections = try jsonDecoder.decode([NetworkShopCategoryData].self, from: data)
                        
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
    
    /// Download or extract from cache preview image
    static func setupPreviewImage(in shop: ShopData, completionHandler: (() -> Void)? = nil) {
           let op = SetupPreviewImageOperation(shop: shop)
           op.completionBlock = completionHandler
           queue.addOperation(op)
    }
    /// Download or extract from cache image
    static func setupImage(in shop: ShopData, completionHandler: (() -> Void)? = nil) {
           let op = SetupImageOperation(shop: shop)
           op.completionBlock = completionHandler
           queue.addOperation(op)
    }
}
