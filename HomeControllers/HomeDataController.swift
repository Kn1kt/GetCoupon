//
//  HomeDataController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HomeDataController {
  
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let disposeBag = DisposeBag()
  private let _collections = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  let collections: Observable<[ShopCategoryData]> //= {
//    return _collections
//      .asObservable()
//      .share()
//  }()
  
  func section(for index: Int) -> Observable<ShopCategoryData>? {
    guard index >= 0, _collections.value.count > index else {
      return nil
    }
    
    let section = collections.map { (categories: [ShopCategoryData]) -> ShopCategoryData in
//      guard index >= 0, categories.count > index else {
//        fatalError("Index overbound")
//      }
      return categories[index]
    }
    
    return section
  }
  
  func category(for shop: ShopData) -> ShopCategoryData {
    guard let category = _collections.value.first(where: { $0.shops.contains(shop) }) else {
      fatalError("No category")
    }
    
    return category
  }
  
  init(collections: Observable<[ShopCategoryData]>) {
    self.collections = _collections.share(replay: 1)
    
    collections.map { (collections: [ShopCategoryData]) -> [ShopCategoryData] in
      return collections.map { category in
        return ShopCategoryData(categoryName: category.categoryName,
                                shops: Array(category.shops.prefix(10)),
                                tags: category.tags)
      }
    }
    .subscribeOn(defaultScheduler)
    .observeOn(defaultScheduler)
    .bind(to: _collections)
    .disposed(by: disposeBag)
  }
}

  // MARK: - Favorites Updates
extension HomeDataController {
  
  func updateFavoritesCategory(_ category: ShopCategoryData, shops: Set<ShopData>) {
    ModelController.shared.updateFavoritesCategory(category, shops: shops)
  }
}
