//
//  Model.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 25.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import Network
import RxSwift
import RxCocoa

class ModelController {
  
  static let shared = ModelController()
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  
  /// System Permission to Send Push Notifications
  let systemPermissionToPush = BehaviorRelay<Bool>(value: false)
  
  private let _collections =  BehaviorRelay<[ShopCategoryData]>(value: [])
  
  let collections: Observable<[ShopCategoryData]> //{
//    return _collections
//      .asObservable()
//      .share(replay: 1)
//  }
  
  /// Home Collections
  var homeDataController: HomeDataController!
  
  /// Favorites Collections
  var favoritesDataController: FavoritesDataController!
  
  private let _favoriteCollections = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  let favoriteCollections: Observable<[ShopCategoryData]> //{
//    return _favoriteCollections
//      .asObservable()
//      .share(replay: 1)
//  }
  
  /// Search Collection
  private let _searchCollection = BehaviorRelay<ShopCategoryData>(value: ShopCategoryData(categoryName: "Empty"))
  
  let searchCollection: Observable<ShopCategoryData> //{
//    return _searchCollection
//      .asObservable()
//      .share(replay: 1)
//  }
  
  var currentSearchCollection: ShopCategoryData {
    return _searchCollection.value
  }
  
  init() {
    self.collections = _collections
      .share(replay: 1)
    self.favoriteCollections = _favoriteCollections
      .share(replay: 1)
    self.searchCollection = _searchCollection
      .share(replay: 1)
    
    homeDataController = HomeDataController(collections: collections)
    favoritesDataController = FavoritesDataController(collections: favoriteCollections)
    
    bindFavorites()
    bindSearch()
  }
}

  // MARK: - Data Management
extension ModelController {
  
  func setupCollections() {
    NetworkController.shared.downloadCollections()
      .observeOn(defaultScheduler)
      .subscribe(onNext: { networkCollections in
        let cache = CacheController()
        cache.updateData(with: networkCollections)
        self.loadCollectionsFromStorage()
      })
      .disposed(by: disposeBag)
  }
  
  func loadCollectionsFromStorage() {
    let cache = CacheController()
    cache.categories()
      .map { (cachedCategories: [ShopCategoryStoredData]) -> [ShopCategoryData] in
        return cachedCategories.map { cachedCategory in
          
          let category = ShopCategoryData(categoryName: cachedCategory.categoryName,
                                          tags: Array(cachedCategory.tags))
          let shops = cachedCategory.shops.map { ShopData($0, category: category) }
          category.shops = Array(shops)
          
          return category
        }
      }
    .observeOn(defaultScheduler)
    .bind(to: _collections)
    .disposed(by: disposeBag)
  }
}

  // MARK: - Favorites Section Data Controller
extension ModelController {
  
  private func bindFavorites() {
    collections
    .map { (collections: [ShopCategoryData]) -> [ShopCategoryData] in
      collections.reduce(into: [ShopCategoryData]()) { result, category in
        let shops = category.shops.filter { $0.isFavorite }
        if !shops.isEmpty {
          result.append(ShopCategoryData(categoryName: category.categoryName,
                                         shops: shops,
                                         tags: category.tags))
        }
      }
    }
    .subscribeOn(defaultScheduler)
    .observeOn(defaultScheduler)
    .bind(to: _favoriteCollections)
    .disposed(by: disposeBag)
  }
  
  func updateFavoritesCollections(with collections: [ShopCategoryData]) {
    _favoriteCollections.accept(collections)
  }
  
  func updateFavoritesCategory(_ category: ShopCategoryData, shops: Set<ShopData>) {
    var favoriteCategories = _favoriteCollections.value
    
    if let updatingCategoryIndex = favoriteCategories.firstIndex(where: { $0.categoryName == category.categoryName }) {
      let newShops = favoriteCategories[updatingCategoryIndex].shops.filter { shop in
        guard shop.isFavorite,
          !shops.contains(shop) else {
          return false
        }
        
        return true
      }
        + shops
      
      if newShops.isEmpty {
        favoriteCategories.remove(at: updatingCategoryIndex)
      } else {
        favoriteCategories[updatingCategoryIndex].shops = newShops
      }
    } else if !shops.isEmpty {
      let newCategory = ShopCategoryData(categoryName: category.categoryName,
                                         shops: Array(shops),
                                         tags: category.tags)
      favoriteCategories.append(newCategory)
    }

    _favoriteCollections.accept(favoriteCategories)
  }
  
  func updateFavoritesCategory(_ category: ShopCategoryData, shop: ShopData) {
    var favoriteCategories = _favoriteCollections.value
    
    if let updatingCategoryIndex = favoriteCategories.firstIndex(where: { $0.categoryName == category.categoryName }) {
      let updatingCategory = favoriteCategories[updatingCategoryIndex]
      
      if shop.isFavorite {
        updatingCategory.shops.append(shop)
      } else if let index = updatingCategory.shops.firstIndex(of: shop) {
        updatingCategory.shops.remove(at: index)
      }
      
      if updatingCategory.shops.isEmpty {
        favoriteCategories.remove(at: updatingCategoryIndex)
      }
    } else {
      guard shop.isFavorite else { fatalError("SHOP \(shop.name) NOT FAVORITE") }
      
      let newCategory = ShopCategoryData(categoryName: category.categoryName,
                                         shops: [shop],
                                         tags: category.tags)
      
      favoriteCategories.append(newCategory)
    }
    
    _favoriteCollections.accept(favoriteCategories)
  }
}

  // MARK: - Search Data
extension ModelController {
  
  private func bindSearch() {
    collections
    .map { (collections: [ShopCategoryData]) -> ShopCategoryData in
      let shops = collections.flatMap { $0.shops }
      
      return ShopCategoryData(categoryName: "Search",
                              shops: shops,
                              tags: [])
    }
    .subscribeOn(defaultScheduler)
    .observeOn(defaultScheduler)
    .bind(to: _searchCollection)
    .disposed(by: disposeBag)
  }
  
  func category(for shop: ShopData) -> ShopCategoryData {
    guard let category = _collections.value.first(where: { $0.shops.contains(shop) }) else {
      fatalError("No category")
    }
    
    return category
  }
}

  // MARK: - Settings Controller functions
extension ModelController {
  
  func removeAllFavorites() {
    let favorites = _favoriteCollections.value
    guard !favorites.isEmpty else {
      return
    }
    
    let cache = CacheController()
    favorites.forEach { category in
      category.shops.forEach { shop in
        shop.isFavorite = false
        shop.favoriteAddingDate = nil
        
        cache.shop(with: shop.name, isFavorite: false, date: nil)
      }
    }
    
    _favoriteCollections.accept([])
  }
  
  func clearImageCache() {
    let cache = CacheController()
    
    cache.clearImageCache()
  }
  
  func removeCollectionsFromStorage() {
    let cache = CacheController()
    
    cache.removeCollectionsFromStorage()
//    do {
//      cache.clearImageCache()
//      try cache.realm.write {
//        cache.realm.deleteAll()
//      }
//    } catch {
//      debugPrint(error.localizedDescription)
//    }
//
//    debugPrint("Deleted From Storage")
  }
}
