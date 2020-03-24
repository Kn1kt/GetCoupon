//
//  FavoritesDataController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 25.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FavoritesDataController {
  
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let disposeBag = DisposeBag()
  
  private let _collectionsBySections = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  var collectionsBySections: Observable<[ShopCategoryData]> {
    return _collectionsBySections
      .asObservable()
      .share(replay: 1)
  }
  
  var currentCollectionsBySections: [ShopCategoryData] {
    return _collectionsBySections.value
  }

  private let _collectionsByDates = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  var collectionsByDates: Observable<[ShopCategoryData]> {
    return _collectionsByDates
      .asObservable()
      .share(replay: 1)
  }
  
  var currentCollectionsByDates: [ShopCategoryData] {
    return _collectionsByDates.value
  }
  
  init(collections: Observable<[ShopCategoryData]>) {
    collections
      .observeOn(defaultScheduler)
      .bind(to: _collectionsBySections)
      .disposed(by: disposeBag)
    
    setupCollectionsByDates()
  }
  
  private func setupCollectionsByDates() {
    _collectionsBySections
      .map { (collections: [ShopCategoryData]) -> [ShopCategoryData] in
        let shops = collections
          .flatMap { category in
            return category.shops
          }
          .sorted { lhs, rhs in
            guard let lhsDate = lhs.favoriteAddingDate,
              let rhsDate = rhs.favoriteAddingDate else {
                fatalError("\(lhs) or \(rhs) doesn't contain favoritesAddingDate")
            }
            return lhsDate > rhsDate
          }
        let name = shops.isEmpty ? "" : "Dates"
        return [ShopCategoryData(categoryName: name,
                                shops: shops)]
      }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: _collectionsByDates)
      .disposed(by: disposeBag)
  }
  
  func category(for shop: ShopData) -> ShopCategoryData {
    guard let category = _collectionsBySections.value.first(where: { $0.shops.contains(shop) }) else {
      fatalError("No category")
    }
    
    return category
  }
}
  // MARK: - Favorites Updates
extension FavoritesDataController {
  
  func updateFavorites() {
    let categories = currentCollectionsBySections.reduce(into: [ShopCategoryData]()) { result, category in
      let shops = category.shops.filter { $0.isFavorite }
      
      if !shops.isEmpty {
        category.shops = shops
        result.append(category)
      }
    }
    
    ModelController.shared.updateFavoritesCollections(with: categories)
  }
}
