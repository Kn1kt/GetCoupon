//
//  NetworkController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 12.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import Foundation
import Network
import RxSwift
import RxCocoa

class NetworkController {
  
  static let shared = NetworkController()
  
  /// Image processing queue
  private let queue = OperationQueue()
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  
  /// Download or extract from cache preview image
  func setupPreviewImage(in shop: ShopData, completionHandler: (() -> Void)? = nil) {
    let op = SetupPreviewImageOperation(shop: shop)
    op.completionBlock = completionHandler
    queue.addOperation(op)
  }
  /// Download or extract from cache image
  func setupImage(in shop: ShopData, completionHandler: (() -> Void)? = nil) {
    let op = SetupImageOperation(shop: shop)
    op.completionBlock = completionHandler
    queue.addOperation(op)
  }
}

  // MARK: - Download database
extension NetworkController {
  
  func downloadCollections() -> Observable<[NetworkShopCategoryData]> {
    let subject = PublishSubject<[NetworkShopCategoryData]>()
    
    let queue = DispatchQueue(label: "monitor")
    let monitor = NWPathMonitor()
    monitor.start(queue: queue)
    monitor.pathUpdateHandler = { [unowned self] currentPath in
      guard currentPath.status == .satisfied,
        let url = URL(string: "https://www.dropbox.com/s/qge216pbfilhy08/collections.json?dl=1") else {
          return
      }
      
      monitor.cancel()
      
      URLSession.shared.rx.data(request: URLRequest(url: url))
        .map { data in
          let decoder = JSONDecoder()
          return try decoder.decode([NetworkShopCategoryData].self, from: data)
      }
      .subscribeOn(self.defaultScheduler)
      .observeOn(self.defaultScheduler)
      .bind(to: subject)
      .disposed(by: self.disposeBag)
    }
    
    return subject.asObservable()
  }
}
