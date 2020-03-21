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

//protocol SnapshotUpdaterProtocol {
//    func updateSnapshot()
//}

class FavoritesDataController {
  
  //    var snapshotUpdater: SnapshotUpdaterProtocol?
  
  //    var needUpdateDates: Bool = true
  
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let disposeBag = DisposeBag()
  
//  private var _collectionsBySections: [ShopCategoryData] = []
  
  private let _collectionsBySections = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  var collectionsBySections: Observable<[ShopCategoryData]> {
    return _collectionsBySections
      .asObservable()
      .share(replay: 1)
  }
  
  var currentCollectionsBySections: [ShopCategoryData] {
    return _collectionsBySections.value
  }
  
//  private let collectionsBySectionsQueue = DispatchQueue(label: "collectionsBySectionsQueue", attributes: .concurrent)
//  var collectionsBySections: [ShopCategoryData] {
//    get {
//      collectionsBySectionsQueue.sync {
//        return _collectionsBySections
//      }
//    }
//
//    set {
//      collectionsBySectionsQueue.async(flags: .barrier) { [weak self] in
//        self?._collectionsBySections = newValue
//        self?.needUpdateDates = true
//        self?.snapshotUpdater?.updateSnapshot()
//      }
//    }
//  }
  
//  private var _collectionsByDates: [ShopData] = []
  private let _collectionsByDates = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  var collectionsByDates: Observable<[ShopCategoryData]> {
    return _collectionsByDates
      .asObservable()
      .share(replay: 1)
  }
  
  var currentCollectionsByDates: [ShopCategoryData] {
    return _collectionsByDates.value
  }
  
//  var collectionsByDates: [ShopData] {
//    get {
//      if needUpdateDates {
//        needUpdateDates = false
//        setupCollectionsByDates()
//      }
//
//      return _collectionsByDates
//    }
//  }
  
  init(collections: Observable<[ShopCategoryData]>) {
//    collectionsBySections = collections
//    snapshotUpdater?.updateSnapshot()
    collections
      .observeOn(defaultScheduler)
      .bind(to: _collectionsBySections)
      .disposed(by: disposeBag)
    
    setupCollectionsByDates()
  }
  
  private func setupCollectionsByDates() {
    
//    _collectionsByDates = []
//    collectionsBySections.forEach { section in
//      _collectionsByDates.append(contentsOf: section.shops)
//    }
//
//    _collectionsByDates.sort { lhs, rhs in
//      return lhs.favoriteAddingDate! > rhs.favoriteAddingDate!
//    }
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

//// MARK: - Collections Management
//extension FavoritesDataController {
//
//  func checkCollection() {
//    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//      guard let self = self else { return }
//      var needUpdate = false
//
//      var deleted = Set<ShopData>()
//
//      let filtered = self.collectionsBySections.filter { section in
//        let shops = section.shops.filter { cell in
//          if !cell.isFavorite {
//            deleted.insert(cell)
//            cell.favoriteAddingDate = nil
//            needUpdate = true
//            return false
//          }
//
//          return true
//        }
//
//        if shops.isEmpty {
//          return false
//        } else if shops.count != section.shops.count {
//          section.shops = shops
//        }
//
//        return true
//      }
//
//      if needUpdate {
//        self.collectionsBySections = filtered
//        ModelController.updateFavoritesCollections(with: filtered)
//      }
//
//      DispatchQueue.global(qos: .utility).async {
//        let cache = CacheController()
//        deleted.forEach {
//          cache.shop(with: $0.name, isFavorite: $0.isFavorite, date: $0.favoriteAddingDate)
//        }
//      }
//    }
//  }
//}

//// MARK: - Search
//extension FavoritesDataController {
//
//  func filteredCollectionBySections(with filter: String) -> [ShopCategoryData] {
//    if filter.isEmpty {
//      return collectionsBySections
//    }
//    let lowercasedFilter = filter.lowercased()
//
//    let filtered = collectionsBySections.reduce(into: [ShopCategoryData]()) { result, section in
//      let shops = section.shops.filter { cell in
//        return cell.name.lowercased().contains(lowercasedFilter)
//      }
//
//      if !shops.isEmpty {
//        result.append(ShopCategoryData(categoryName: section.categoryName, shops: shops.sorted { $0.name < $1.name }))
//      }
//
//    }
//
//    return filtered
//  }
//
//  func filteredCollectionByDates(with filter: String) -> [ShopData] {
//    if filter.isEmpty {
//      return collectionsByDates
//    }
//    let lowercasedFilter = filter.lowercased()
//
//    let filtered = collectionsByDates.filter { cell in
//      return cell.name.lowercased().contains(lowercasedFilter)
//    }
//
//    return filtered
//  }
//}
