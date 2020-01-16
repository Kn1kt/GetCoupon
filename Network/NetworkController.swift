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
    
    static func setupImage(at indexPath: IndexPath, with cellData: ShopData, completionHandler: (() -> Void)? = nil) {
           let op = SetupPreviewImageOperation(shop: cellData)
           op.completionBlock = completionHandler
           queue.addOperation(op)
    }
}
