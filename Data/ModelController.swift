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
  
  private let _collections =  BehaviorRelay<[ShopCategoryData]>(value: [])
  
  var collections: Observable<[ShopCategoryData]> {
    return _collections
      .asObservable()
      .share(replay: 1)
  }
  
//  static fileprivate var _collections: [ShopCategoryData] = []
//  static private let collectionsQueue = DispatchQueue(label: "collectionsQueue", attributes: .concurrent)
  
//  /// Main Collections
//  static var collections: [ShopCategoryData] {
//    get {
//      collectionsQueue.sync {
//        return _collections
//      }
//    }
//
//    set {
//      collectionsQueue.async(flags: .barrier) {
//        self._collections = newValue
//        NotificationCenter.default.post(name: .didUpdateCollections, object: nil)
//      }
//    }
//  }
  
  /// Home Collections
  var homeDataController: HomeDataController!
  
  /// Favorites Collections
  var favoritesDataController: FavoritesDataController!
  
  private let _favoriteCollections = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  var favoriteCollections: Observable<[ShopCategoryData]> {
    return _favoriteCollections
      .asObservable()
      .share(replay: 1)
  }
  
//  static private var _favoritesCollections: [ShopCategoryData] = []
//
//  static private let favoritesCollectionsQueue = DispatchQueue(label: "favoritesCollectionsQueue", attributes: .concurrent)
//  static private var favoritesCollections: [ShopCategoryData] {
//    get {
//      favoritesCollectionsQueue.sync {
//        return _favoritesCollections
//      }
//    }
//
//    set {
//      favoritesCollectionsQueue.async(flags: .barrier) {
//        self._favoritesCollections = newValue
//        self.favoritesDataController.collectionsBySections = newValue
//      }
//    }
//  }
  
  /// Search Collection
  private let _searchCollection = BehaviorRelay<ShopCategoryData>(value: ShopCategoryData(categoryName: "Empty"))
  
  var searchCollection: Observable<ShopCategoryData> {
    return _searchCollection
      .asObservable()
      .share(replay: 1)
  }
  
  var currentSearchCollection: ShopCategoryData {
    return _searchCollection.value
  }
  
//  static var _searchCollection: ShopCategoryData = ShopCategoryData(categoryName: "Empty")
//  static private let searchCollectionQueue = DispatchQueue(label: "searchCollectionQueue", attributes: .concurrent)
//  static var searchCollection: ShopCategoryData {
//    get {
//      searchCollectionQueue.sync {
//        return _searchCollection
//      }
//    }
//
//    set {
//      searchCollectionQueue.async(flags: .barrier) {
//        self._searchCollection = newValue
//        NotificationCenter.default.post(name: .didUpdateSearchCollections, object: nil)
//      }
//    }
//  }
  
  init() {
    homeDataController = HomeDataController(collections: collections)
    favoritesDataController = FavoritesDataController(collections: favoriteCollections)
    
    _favoriteCollections
      .subscribe(onNext: { c in
        print(c)
      })
      .disposed(by: disposeBag)
    
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
        print("received")
        let cache = CacheController()
        cache.updateData(with: networkCollections)
        self.loadCollectionsFromStorage()
      })
      .disposed(by: disposeBag)
//      .subscribeOn(defaultScheduler)
//      .subscribe(onNext: { _ in
//        print("recieved")
//      })
  }
  
  func loadCollectionsFromStorage() {
    let cache = CacheController()
    cache.categories()
      .map { (cachedCategories: [ShopCategoryStoredData]) -> [ShopCategoryData] in
        return cachedCategories.map { cachedCategory in
          
          let shops = cachedCategory.shops.map(ShopData.init)
          return ShopCategoryData(categoryName: cachedCategory.categoryName,
                                  shops: Array(shops),
                                  tags: Array(cachedCategory.tags))
        }
      }
//    .subscribeOn(defaultScheduler)
    .observeOn(defaultScheduler)
    .bind(to: _collections)
    .disposed(by: disposeBag)
  }
  
//  static func setupCollections() {
//    NetworkController.downloadDataBase()
//  }
//
//  static func loadCollectionsFromStorage() {
//
//    DispatchQueue.global(qos: .userInitiated).async {
//      let cache = CacheController()
//      let categories = cache.categories()
//      var favoriteCollections = [ShopCategoryData]()
//
//      let collections = categories.reduce(into: [ShopCategoryData]()) { result, storedCategory in
//        let category = ShopCategoryData(categoryName: storedCategory.categoryName,
//                                        tags: Array(storedCategory.tags))
//        let shops = Array(storedCategory.shops).reduce(into: [ShopData]()) { result, storedShop in
//          let shop = ShopData(storedShop)
//          if shop.isFavorite {
//            insert(in: &favoriteCollections, shop: shop, categoryName: category.categoryName)
//          }
//          result.append(shop)
//        }
//
//        if !shops.isEmpty {
//          category.shops = shops
//          result.append(category)
//        }
//      }
//
//      self.collections = collections
//      self.favoritesCollections = favoriteCollections
//
//      setupSearchData()
//
//      debugPrint("loaded Collections from storage")
//    }
//  }
//
//  static private func insert(in collection: inout [ShopCategoryData], shop: ShopData, categoryName: String) {
//
//    if let sectionIndex = collection.firstIndex(where: { $0.categoryName == categoryName }) {
//      collection[sectionIndex].shops.append(shop)
//    } else {
//      collection.append(ShopCategoryData(categoryName: categoryName, shops: [shop]))
//      collection.sort { $0.categoryName < $1.categoryName }
//    }
//  }
//
//  static func removeCollectionsFromStorage() {
//    let cache = CacheController()
//    try! cache.realm.write {
//      cache.realm.deleteAll()
//    }
//    debugPrint("deleted from storage")
//  }
//
//
//  static func section(for index: Int) -> ShopCategoryData? {
//    guard index >= 0, collections.count > index else { return nil }
//
//    return collections[index]
//  }
}

  // MARK: - Home Section Data Controller
extension ModelController {
  
//  private func createHomeDataController() -> HomeDataController {
//    let controller = HomeDataController()
//
//    return controller
//  }
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
    
//    favoritesCollections = collections
//    NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
  }
  
//  func updateFavoritesCategory(_ category: ShopCategoryData) {
//    var favoriteCategories = _favoriteCollections.value
//    let favoriteShops = category.shops.filter { $0.isFavorite }
//
//    if let updatingCategoryIndex = favoriteCategories.firstIndex(where: { $0.categoryName == category.categoryName }) {
//      if favoriteShops.isEmpty {
//        favoriteCategories.remove(at: updatingCategoryIndex)
//      } else {
//        favoriteCategories[updatingCategoryIndex].shops = favoriteShops
//      }
//
//    } else if !favoriteCategories.isEmpty {
//      let newCategory = ShopCategoryData(categoryName: category.categoryName,
//                                         shops: favoriteShops,
//                                         tags: category.tags)
//      favoriteCategories.append(newCategory)
//    }
//
//    _favoriteCollections.accept(favoriteCategories)
//  }
  
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
  
//  static func insertInFavorites(shop: ShopData) {
//
//    let section = collections.first { section in
//      if section.shops.contains(shop) {
//        return true
//      }
//      return false
//    }
//
//    if let sectionIndex = favoritesCollections.firstIndex(where: { $0.categoryName == section!.categoryName }) {
//      favoritesCollections[sectionIndex].shops.append(shop)
//    } else {
//      favoritesCollections.append(ShopCategoryData(categoryName: section!.categoryName, shops: [shop]))
//      favoritesCollections.sort { $0.categoryName < $1.categoryName }
//    }
//
//    NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
//    favoritesDataController.collectionsBySections = favoritesCollections
//  }
  
//  static func deleteFromFavorites(shop: ShopData) {
//
//    let section = collections.first { section in
//      if section.shops.contains(shop) {
//        return true
//      }
//      return false
//    }
//
//    if let sectionIndex = favoritesCollections.firstIndex(where: { $0.categoryName == section!.categoryName }) {
//      if let removeIndex = favoritesCollections[sectionIndex].shops.firstIndex(where: { $0.identifier == shop.identifier }) {
//        favoritesCollections[sectionIndex].shops.remove(at: removeIndex)
//      }
//
//      if favoritesCollections[sectionIndex].shops.isEmpty {
//        favoritesCollections.remove(at: sectionIndex)
//        favoritesCollections.sort { $0.categoryName < $1.categoryName }
//      }
//    }
//
//    NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
//    favoritesDataController.collectionsBySections = favoritesCollections
//  }
  
//  static func updateFavoritesCollections(in name: String,
//                                         added addedCells: Set<ShopData>,
//                                         deleted deletedCells: Set<ShopData>) {
//    if let sectionIndex = favoritesCollections.firstIndex(where: { $0.categoryName == name }) {
//      let section = favoritesCollections[sectionIndex]
//
//      var reduced = section.shops.filter { shop in
//        if addedCells.contains(shop) ||
//          deletedCells.contains(shop){
//          return false
//        }
//        return true
//      }
//
//      reduced.append(contentsOf: addedCells)
//
//      if reduced.isEmpty {
//        favoritesCollections.remove(at: sectionIndex)
//
//      } else {
//        section.shops = reduced
//      }
//
//    } else {
//      if !addedCells.isEmpty {
//        favoritesCollections.append(ShopCategoryData(categoryName: name, shops: Array(addedCells)))
//      }
//    }
//
//    favoritesCollections.sort { $0.categoryName < $1.categoryName }
//    favoritesDataController.collectionsBySections = favoritesCollections
//  }
  
//  static func removeAllFavorites() {
//
//    guard !favoritesCollections.isEmpty else {
//      return
//    }
//
//    favoritesCollections.forEach { section in
//      let cache = CacheController()
//      section.shops.forEach { shop in
//        shop.isFavorite = false
//        cache.shop(with: shop.name, isFavorite: false)
//      }
//    }
//    favoritesCollections = []
//    NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
//  }
  
//  private func createFavoritesDataController() -> FavoritesDataController {
//    let controller = FavoritesDataController(collections: favoritesCollections)
//
//    return controller
//  }
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
  
//  static private func setupSearchData() {
//    DispatchQueue.global(qos: .utility).async {
//      let shops = collections.reduce(into: [ShopData]()) { result, section in
//        result.append(contentsOf: section.shops)
//      }
//
//      let newCategory = ShopCategoryData(categoryName: "Search", shops: shops)
//      searchCollection = newCategory
//    }
//  }
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
  
  func removeCollectionsFromStorage() {
    let cache = CacheController()
    try! cache.realm.write {
      cache.realm.deleteAll()
    }
    debugPrint("deleted from storage")
  }
}
