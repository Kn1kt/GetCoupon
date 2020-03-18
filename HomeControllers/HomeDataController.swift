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
  
//  var collections: [ShopCategoryData] = []
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let disposeBag = DisposeBag()
  private let _collections = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  var collections: Observable<[ShopCategoryData]> {
    return _collections
      .asObservable()
      .share()
  }
  
  func section(for index: Int) -> Observable<ShopCategoryData> {
    let section = collections.map { (categories: [ShopCategoryData]) -> ShopCategoryData in
      guard index >= 0, categories.count > index else { fatalError("Index overbound") }
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
    
//    NotificationCenter.default.addObserver(self, selector: #selector(HomeDataController.updateCollections), name: .didUpdateCollections, object: nil)
  }
  
  deinit {
//    NotificationCenter.default.removeObserver(self, name: .didUpdateCollections, object: nil)
  }
}

  // MARK: - Favorites Updates
extension HomeDataController {
  
  func updateFavoritesCategory(_ category: ShopCategoryData, shops: Set<ShopData>) {
    ModelController.shared.updateFavoritesCategory(category, shops: shops)
  }
}

  // MARK: - Updating
extension HomeDataController {
  
//  @objc func updateCollections() {
//    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//      let collections = ModelController.collections.reduce(into: [ShopCategoryData]()){ result, section in
//
//        let shops = Array(section.shops.prefix(10))
//
//        let reducedSection = ShopCategoryData(categoryName: section.categoryName,
//                                              shops: shops)
//
//        result.append(reducedSection)
//      }
//
////      self?.collections = collections
//      self?._collections.accept(collections)
//      NotificationCenter.default.post(name: .didUpdateHome, object: nil)
//    }
//
//  }
}
