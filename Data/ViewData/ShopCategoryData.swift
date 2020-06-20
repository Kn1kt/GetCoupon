//
//  ShopCategoryData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 09.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ShopCategoryData {
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  
  let categoryName: String
  
  let tags: Set<String>
  
  var shops: [ShopData]
  
  let identifier = UUID()
  
  let defaultImageLink: String
  let defaultImage = BehaviorRelay<UIImage?>(value: nil)
  
  init(categoryName: String,
       defaultImageLink: String = "",
       shops: [ShopData] = [],
       tags: Set<String> = []) {
    self.categoryName = categoryName
    self.defaultImageLink = defaultImageLink
    self.shops = shops
    self.tags = tags
    
//    Observable<UIImage>
//      .create { [weak self] observer in
//        guard let self = self else {
//          observer.onCompleted()
//          return Disposables.create()
//        }
//        
//        print("DEFAULT IMAGE: Subscribe on \(Thread.current)")
//        
//        let cache = CacheController()
//        if let image = cache.defaultImage(for: categoryName) {
//          observer.onNext(image)
//          observer.onCompleted()
//          
//        } else {
//          NetworkController.shared.downloadImage(for: defaultImageLink)
//            .take(1)
//            .subscribe(onNext: { image in
//              observer.onNext(image)
//              observer.onCompleted()
//              
//              let cache = CacheController()
//              cache.cacheDefaultImage(image, for: categoryName)
//            }, onError: { error in
//              observer.onCompleted()
//            })
//            .disposed(by: self.disposeBag)
//        }
//        
//        return Disposables.create()
//      }
//      .share(replay: 1, scope: .forever)
  }
  
  /// Bridge for stored data
  convenience init(_ category: ShopCategoryStoredData) {
    let tags = Set(category.tags)
    self.init(categoryName: category.categoryName,
              defaultImageLink: category.defaultImageLink,
              tags: tags)
    
    let shops = Array(category.shops).map { ShopData($0, category: self) }
    self.shops = shops
  }
}

  // MARK: - Hashable
extension ShopCategoryData: Hashable {
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  static func == (lhs: ShopCategoryData, rhs: ShopCategoryData) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}
