//
//  FavoritesViewModel.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 15.03.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FavoritesViewModel {
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private var navigator: Navigator!
  private var model: FavoritesDataController!
  
  // MARK: - Input
  let segmentIndex = BehaviorRelay<Int>(value: 0)
  
  let refresh = BehaviorRelay<Bool>(value: false)
  
  let searchText = BehaviorRelay<String>(value: "")
  
  let editedShops = PublishRelay<ShopData>()
  
  let commitChanges = PublishRelay<Void>()
  
  let showShopVC = PublishRelay<(UIViewController, ShopData)>()
  
  // MARK: - Output
  private let _currentSection = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  var currentSection: Driver<[ShopCategoryData]> {
    return _currentSection
      .asDriver()
  }
  
  private let _isRefreshing = BehaviorRelay<Bool>(value: false)
  
  var isRefreshing: Driver<Bool> {
    return _isRefreshing
      .asDriver()
  }
  
  // MARK: - Init
  init() {
    self.navigator = Navigator()
    self.model = ModelController.shared.favoritesDataController
    
    bindOutput()
    bindActions()
  }
  
  private func bindOutput() {
    model.collectionsBySections
      .map { _ in }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        
        let searchText = self.searchText.value
        if !searchText.isEmpty {
          self.searchText.accept(searchText)
          return
        }
        
        let segmentIndex = self.segmentIndex.value
        self.segmentIndex.accept(segmentIndex)
      })
      .disposed(by: disposeBag)
    
    segmentIndex
      .filter { [weak self] _ in
        guard let self = self else { fatalError("SegmentIndexFilter") }
        return self.searchText.value.isEmpty
      }
      .map { [weak self] (index: Int) -> [ShopCategoryData] in
        guard let self = self else { fatalError("SegmentIndexMap") }
        
        switch index {
        case 1:
          return self.model.currentCollectionsByDates
        default:
          return self.model.currentCollectionsBySections
        }
      }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: _currentSection)
      .disposed(by: disposeBag)
    
    searchText
      .skip(1)
      .map { [weak self] (text: String) -> [ShopCategoryData] in
        guard let self = self else { fatalError("searchText") }
        return self.filteredCategories(with: text)
      }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: _currentSection)
      .disposed(by: disposeBag)
    
    model.collectionsBySections
      .map { _ in false }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: _isRefreshing)
      .disposed(by: disposeBag)
  }
  
  private func bindActions() {
    
    let unicEditedShops = BehaviorRelay<Set<ShopData>>(value: [])
    
//    let unicEditedShops = editedShops
//      .scan(into: Set<ShopData>()) { result, shop in
//          result.insert(shop)
//    }
//    .subscribeOn(defaultScheduler)
    
    editedShops
      .observeOn(defaultScheduler)
      .subscribe(onNext: { shop in
        var set = unicEditedShops.value
        set.insert(shop)
        unicEditedShops.accept(set)
      })
      .disposed(by: disposeBag)
    
    commitChanges
      .withLatestFrom(unicEditedShops)
      .filter { shops in
        return !shops
          .filter { !$0.isFavorite }
          .isEmpty
      }
      .map { _ in }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.model.updateFavorites()
        unicEditedShops.accept([])
      })
      .disposed(by: disposeBag)
    
    commitChanges
      .withLatestFrom(unicEditedShops)
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .subscribe(onNext: { shops in
        let cache = CacheController()
        shops.forEach { shop in
          cache.shop(with: shop.name,
                     isFavorite: shop.isFavorite,
                     date: shop.favoriteAddingDate)
        }
      })
      .disposed(by: disposeBag)
    
    refresh
      .filter { $0 }
      .map { _ in }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: commitChanges)
      .disposed(by: disposeBag)
    
    refresh
      .filter { $0 }
      .map { _ in false }
      .delay(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: _isRefreshing)
      .disposed(by: disposeBag)
    
    showShopVC
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] (vc, shop) in
        let section = self.model.category(for: shop)
        self.showShopVC(vc, section: section, shop: shop)
      })
      .disposed(by: disposeBag)
    
    showShopVC
    .map { _ in }
    .subscribeOn(defaultScheduler)
    .observeOn(defaultScheduler)
    .bind(to: commitChanges)
    .disposed(by: disposeBag)
  }
}

  // MARK: - Setup Image
extension FavoritesViewModel {
  
  func setupImage(for shop: ShopData) -> Completable {
    let subject = PublishSubject<Void>()
    NetworkController.shared.setupPreviewImage(in: shop) {
      subject.onCompleted()
    }
    
    return subject
      .asObservable()
      .take(1)
      .ignoreElements()
  }
}

  // MARK: - Update Shop isFavorite property
extension FavoritesViewModel {
  
  func updateFavorites(_ sender: AddToFavoritesButton) {
    guard let shop = sender.cell else { return }
    
    shop.isFavorite = !shop.isFavorite
    
    shop.favoriteAddingDate = shop.isFavorite ? Date(timeIntervalSinceNow: 0) : nil
  }
}

  //MARK: - Performing Search
extension FavoritesViewModel {
  
  private func filteredCategories(with filter: String) -> [ShopCategoryData] {
    
    let categories = segmentIndex.value == 0 ? model.currentCollectionsBySections : model.currentCollectionsByDates
    
    if filter.isEmpty {
      return categories
    }
    
    let lowercasedFilter = filter.lowercased()
    let filtered = categories.reduce(into: [ShopCategoryData]()) { result, category in
      let shops = category.shops
        .filter { shop in
          return shop.name.lowercased().contains(lowercasedFilter)
        }
        .sorted { $0.name < $1.name }
      
      if !shops.isEmpty {
        result.append(ShopCategoryData(categoryName: category.categoryName,
                              shops: shops,
                              tags: category.tags))
      }
    }
    
    return filtered
  }
}

  // MARK: - Show Shop View Controller
extension FavoritesViewModel {
  
  private func showShopVC(_ vc: UIViewController, section: ShopCategoryData, shop: ShopData) {
    navigator.showShopVC(sender: vc, section: section, shop: shop)
  }
}
