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
  
  enum DataStatus {
    case updating, updated, waitingForNetwork, unknown
    case error(Error)
  }
  
  static let shared = ModelController()
  
  private let disposeBag = DisposeBag()
  private var updateDisposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let updatesScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
  
  /// System Permission to Send Push Notifications
  let systemPermissionToPush = BehaviorRelay<Bool>(value: false)
  
  /// Tab Bar Quick Actions
  let defaultTabBarItem = BehaviorRelay<Int>(value: 0)
  
  let _isUpdatingData = BehaviorRelay<Bool>(value: false)
  let isUpdatingData: Observable<Bool>
  
  private let _dataUpdatingStatus = BehaviorRelay<DataStatus>(value: .unknown)
  let dataUpdatingStatus: Observable<DataStatus>
  
  private let _collections = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  let collections: Observable<[ShopCategoryData]>
  
  private let _advData = BehaviorRelay<[AdvertisingCategoryData]>(value: [])
  let advData: Observable<[AdvertisingCategoryData]>
  
  /// Home Collections
  var homeDataController: HomeDataController!
  
  /// Favorites Collections
  var favoritesDataController: FavoritesDataController!
  
  private let _favoriteCollections = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  let favoriteCollections: Observable<[ShopCategoryData]>
  
  /// Search Collection
  private let _searchCollection = BehaviorRelay<ShopCategoryData>(value: ShopCategoryData(categoryName: "Empty"))
  
  let searchCollection: Observable<ShopCategoryData>
  
  var currentSearchCollection: ShopCategoryData {
    return _searchCollection.value
  }
  
  init() {
    self.collections = _collections.share(replay: 1)
    self.favoriteCollections = _favoriteCollections.share(replay: 1)
    self.searchCollection = _searchCollection.share(replay: 1)
    self.isUpdatingData = _isUpdatingData.share(replay: 1)
    self.dataUpdatingStatus = _dataUpdatingStatus.share(replay: 1)
    self.advData = _advData.share(replay: 1)
    
    homeDataController = HomeDataController(collections: collections, advData: advData)
    favoritesDataController = FavoritesDataController(collections: favoriteCollections)
    
    bindFavorites()
    bindSearch()
    bindAdvData()
  }
}

  // MARK: - Data Management
extension ModelController {
  
  func setupCollections() {
    UserDefaults.standard.set(Date(timeIntervalSinceNow: 0),
                              forKey: UserDefaultKeys.lastUpdateDate.rawValue)
    self._dataUpdatingStatus.accept(.updating)
    self._isUpdatingData.accept(true)
    
    self.updateDisposeBag = DisposeBag()
    
    NetworkController.shared.setupServerPack()
      .subscribeOn(updatesScheduler)
      .subscribe(onNext: { [weak self] in
        self?.updateCollections()
        }, onError: { [weak self] error in
          guard let self = self else { return }
          
          self._dataUpdatingStatus.accept(.error(error))
          self._isUpdatingData.accept(false)
          
          self._dataUpdatingStatus.accept(.waitingForNetwork)
          
          NetworkController.shared.connectionStatusSatisfied
            .subscribeOn(self.updatesScheduler)
            .subscribe(onNext: {
              self.setupCollections()
            })
            .disposed(by: self.updateDisposeBag)
      })
      .disposed(by: disposeBag)
  }
  
  private func updateCollections() {
    let networkData = NetworkController.shared.downloadCollections().share()
    
    networkData
      .observeOn(updatesScheduler)
      .subscribe(onNext: { networkCollections in
        let cache = CacheController()
        cache.updateData(with: networkCollections)
        self.loadCollectionsFromStorage()
      },
                 onError: { error in
        self._dataUpdatingStatus.accept(.error(error))
        self._isUpdatingData.accept(false)
      },
                 onCompleted: {
        self._dataUpdatingStatus.accept(.updated)
        self._isUpdatingData.accept(false)
      })
      .disposed(by: disposeBag)
    
    networkData
      .observeOn(updatesScheduler)
      .subscribe(onError: { [weak self] error in
        guard let self = self else { return }
        
        /// Just do nothing when server turn off
        if let error = error as? RxCocoa.RxCocoaURLError,
          case .httpRequestFailed(response: _, data: _) = error {
          return
        }
        
        self._dataUpdatingStatus.accept(.waitingForNetwork)
        
        NetworkController.shared.connectionStatusSatisfied
          .subscribeOn(self.updatesScheduler)
          .subscribe(onNext: {
            self.setupCollections()
          })
          .disposed(by: self.updateDisposeBag)
      })
      .disposed(by: disposeBag)
  }
  
  func loadCollectionsFromStorage() {
    let cache = CacheController()
    cache.categories()
      .map { (cachedCategories: [ShopCategoryStoredData]) -> [ShopCategoryData] in
        return cachedCategories.map(ShopCategoryData.init)
      }
    .observeOn(updatesScheduler)
    .bind(to: _collections)
    .disposed(by: disposeBag)
  }
  
  func setupDefaultImage(for category: ShopCategoryData) -> Completable {
    let subject = PublishSubject<Void>()
    
    DispatchQueue.global(qos: .default).async { [weak self] in
      guard let self = self else {
        subject.onCompleted()
        return
      }
      
      let cache = CacheController()
      if let image = cache.defaultImage(for: category.categoryName) {
        if category.defaultImage.value == nil {
          category.defaultImage.accept(image)
        }
        
        subject.onCompleted()
        
      } else {
        NetworkController.shared.downloadImage(for: category.defaultImageLink)
          .take(1)
          .observeOn(self.defaultScheduler)
          .subscribe(onNext: { image in
            if category.defaultImage.value == nil {
              category.defaultImage.accept(image)
              subject.onCompleted()
              
              let cache = CacheController()
              cache.cacheDefaultImage(image, for: category.categoryName)
            }
            
            subject.onCompleted()
          }, onError: { error in
            subject.onCompleted()
          })
          .disposed(by: self.disposeBag)
      }
    }
    
    
    return subject
    .asObservable()
    .take(1)
    .ignoreElements()
  }
  
  func setupPreviewImage(for shop: ShopData) -> Completable {
    let subject = PublishSubject<Void>()
    
    DispatchQueue.global(qos: .default).async { [weak self] in
      guard let self = self else {
        subject.onCompleted()
        return
      }
      
      let cache = CacheController()
      if let image = cache.previewImage(for: shop.name) {
        if shop.previewImage.value == nil {
          shop.previewImage.accept(image)
        }
        
        subject.onCompleted()
        
      } else {
        NetworkController.shared.downloadImage(for: shop.previewImageLink)
          .take(1)
          .observeOn(self.defaultScheduler)
          .subscribe(onNext: { image in
            if shop.previewImage.value == nil {
              shop.previewImage.accept(image)
              subject.onCompleted()
              
              let cache = CacheController()
              cache.cachePreviewImage(image, for: shop.name)
            }
            
            subject.onCompleted()
          }, onError: { [weak self] _ in
            guard let self = self,
              let category = shop.category else {
                subject.onCompleted()
                return
            }
            
            if let image = category.defaultImage.value {
              shop.previewImage.accept(image)
              subject.onCompleted()
              
            } else {
              self.setupDefaultImage(for: category)
                .subscribe(onCompleted: {
                  if shop.previewImage.value == nil,
                    let image = category.defaultImage.value {
                    shop.previewImage.accept(image)
                  }
                  
                  subject.onCompleted()
                })
                .disposed(by: self.disposeBag)
            }
          })
          .disposed(by: self.disposeBag)
      }
    }
    
    return subject
      .asObservable()
      .take(1)
      .ignoreElements()
  }
  
  func setupImage(for shop: ShopData) -> Completable {
    let subject = PublishSubject<Void>()
    
    DispatchQueue.global(qos: .default).async { [weak self] in
      guard let self = self else {
        subject.onCompleted()
        return
      }
      
      let cache = CacheController()
      if let image = cache.image(for: shop.name) {
        if shop.image.value == nil {
          shop.image.accept(image)
        }
        
        subject.onCompleted()
        
      } else {
        NetworkController.shared.downloadImage(for: shop.imageLink)
          .take(1)
          .observeOn(self.defaultScheduler)
          .subscribe(onNext: { image in
            if shop.image.value == nil {
              shop.image.accept(image)
              
              let cache = CacheController()
              cache.cacheImage(image, for: shop.name)
            }
            subject.onCompleted()
          }, onError: { _ in
            subject.onCompleted()
          })
          .disposed(by: self.disposeBag)
      }
    }
    
    return subject
      .asObservable()
      .take(1)
      .ignoreElements()
  }
  
  func setupAdvImage(for cell: ShopData) -> Completable {
    let subject = PublishSubject<Void>()
    
    DispatchQueue.global(qos: .default).async { [weak self] in
      guard let self = self else {
        subject.onCompleted()
        return
      }
      
      NetworkController.shared.downloadImage(for: cell.previewImageLink)
        .take(1)
        .observeOn(self.defaultScheduler)
        .subscribe(onNext: { image in
          if cell.previewImage.value == nil {
            cell.previewImage.accept(image)
          }
          subject.onCompleted()
        }, onError: { _ in
          subject.onCompleted()
        })
        .disposed(by: self.disposeBag)
    }
    
    return subject
      .asObservable()
      .take(1)
      .ignoreElements()
  }
}

  // MARK: - Home Data Controller
extension ModelController {
  
  func section(for index: Int) -> Observable<ShopCategoryData>? {
    guard index >= 0, _collections.value.count > index else {
      return nil
    }
    
    let section = collections.map { (categories: [ShopCategoryData]) -> ShopCategoryData in
      return categories[index]
    }
    
    return section
  }
}

  // MARK: - Favorites Section Data Controller
extension ModelController {
  
  private func bindFavorites() {
    collections
    .map { (collections: [ShopCategoryData]) -> [ShopCategoryData] in
      return collections
        .reduce(into: [ShopCategoryData]()) { result, category in
          let shops = category.shops.filter { $0.isFavorite }
          if !shops.isEmpty {
            result.append(ShopCategoryData(categoryName: category.categoryName,
                                           shops: shops.sorted(by: { lhs, rhs in
                                            if lhs.priority == rhs.priority {
                                              if let lhsDate = lhs.promoCodes.first?.addingDate {
                                                if let rhsDate = rhs.promoCodes.first?.addingDate {
                                                  return lhsDate > rhsDate
                                                }
                                                return true
                                              }
                                              return false
                                            } else {
                                              return lhs.priority > rhs.priority
                                            }
                                           }),
                                           tags: category.tags))
          }
        }
        .sorted { $0.priority < $1.priority }
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
      let newShops = shops + favoriteCategories[updatingCategoryIndex].shops.filter { shop in
        guard shop.isFavorite,
          !shops.contains(shop) else {
          return false
        }
        
        return true
      }
//        + shops
      
      if newShops.isEmpty {
        favoriteCategories.remove(at: updatingCategoryIndex)
      } else {
        favoriteCategories[updatingCategoryIndex].shops = newShops.sorted(by: { lhs, rhs in
          if lhs.priority == rhs.priority {
            if let lhsDate = lhs.promoCodes.first?.addingDate {
              if let rhsDate = rhs.promoCodes.first?.addingDate {
                return lhsDate > rhsDate
              }
              return true
            }
            return false
          } else {
            return lhs.priority > rhs.priority
          }
        })
      }
    } else if !shops.isEmpty {
      let newCategory = ShopCategoryData(categoryName: category.categoryName,
                                         shops: Array(shops.sorted(by: { lhs, rhs in
                                          if lhs.priority == rhs.priority {
                                            if let lhsDate = lhs.promoCodes.first?.addingDate {
                                              if let rhsDate = rhs.promoCodes.first?.addingDate {
                                                return lhsDate > rhsDate
                                              }
                                              return true
                                            }
                                            return false
                                          } else {
                                            return lhs.priority > rhs.priority
                                          }
                                         })),
                                         tags: category.tags)
      favoriteCategories.append(newCategory)
      favoriteCategories.sort(by: { $0.categoryName < $1.categoryName })
    }
    
    _favoriteCollections.accept(favoriteCategories)
  }
  
  func updateFavoritesCategory(_ category: ShopCategoryData, shop: ShopData) {
    var favoriteCategories = _favoriteCollections.value
    
    if let updatingCategoryIndex = favoriteCategories.firstIndex(where: { $0.categoryName == category.categoryName }) {
      let updatingCategory = favoriteCategories[updatingCategoryIndex]
      
      if shop.isFavorite {
        updatingCategory.shops.append(shop)
        updatingCategory.shops.sort { lhs, rhs in
          if lhs.priority == rhs.priority {
            if let lhsDate = lhs.promoCodes.first?.addingDate {
              if let rhsDate = rhs.promoCodes.first?.addingDate {
                return lhsDate > rhsDate
              }
              return true
            }
            return false
          } else {
            return lhs.priority > rhs.priority
          }
        }
        
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
      favoriteCategories.sort(by: { $0.categoryName < $1.categoryName })
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
  }
}
  // MARK: - Advertising Data
extension ModelController {
  
  func bindAdvData() {
    collections
      .skip(1)
      .debounce(.seconds(2), scheduler: defaultScheduler)
      .map { _ in }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        NetworkController.shared.downloadAdvOffer()
          .observeOn(self.defaultScheduler)
          .subscribe(onNext: { [weak self] networkData in
            let data = networkData.map(AdvertisingCategoryData.init)
            self?._advData.accept(data)
          })
          .disposed(by: self.disposeBag)
      })
      .disposed(by: disposeBag)
  }
}
