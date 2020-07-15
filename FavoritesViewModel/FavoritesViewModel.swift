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
  
  private let trie = BehaviorRelay<Trie<String>>(value: Trie<String>())
  
  // MARK: - Input
  let segmentIndex = BehaviorRelay<Int>(value: 0)
  
  let searchText = BehaviorRelay<String>(value: "")
  
  let editedShops = PublishRelay<ShopData>()
  
  let commitChanges = PublishRelay<Void>()
  
  let showShopVC = PublishRelay<(UIViewController, ShopData)>()
  
  // MARK: - Output
  private let _currentSection = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  let currentSection: Driver<[ShopCategoryData]>
  
  let isUpdatingData: Driver<Bool>
  
  // MARK: - Init
  init() {
    self.navigator = Navigator()
    self.model = ModelController.shared.favoritesDataController
    
    self.currentSection = _currentSection.asDriver()
    self.isUpdatingData = ModelController.shared.isUpdatingData.asDriver(onErrorJustReturn: false)
    
    bindOutput()
    bindActions()
  }
  
  private func bindOutput() {
    model.collectionsByDates
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [weak self] collections in
        guard let self = self else { return }
        if let category = collections.first {
          self.buildTrie(with: category.shops)
        }
        
        let searchText = self.searchText.value
        if !searchText.isEmpty {
          self.searchText.accept(searchText)
          return
        }
        
        let segmentIndex = self.segmentIndex.value
        self.segmentIndex.accept(segmentIndex)
      })
      .disposed(by: disposeBag)
    
    let segmentIndex = self.segmentIndex.share(replay: 1)
    
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
    
    segmentIndex
      .withLatestFrom(searchText)
      .filter { !$0.isEmpty }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: searchText)
      .disposed(by: disposeBag)
    
    searchText
      .skip(1)
      .observeOn(eventScheduler)
      .subscribe(onNext: { [weak self] text in
        guard let self = self else { return }
        self._currentSection.accept(self.filteredCategories(with: text))
      })
      .disposed(by: disposeBag)
  }
  
  private func bindActions() {
    let unicEditedShops = BehaviorRelay<Set<ShopData>>(value: [])
    
    editedShops
      .observeOn(defaultScheduler)
      .subscribe(onNext: { shop in
        var set = unicEditedShops.value
        set.insert(shop)
        unicEditedShops.accept(set)
      })
      .disposed(by: disposeBag)
    
    let commitChanges = self.commitChanges.share()
    
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
    
    let showShopVC = self.showShopVC.share()
    
    showShopVC
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] (vc, shop) in
        let isEnabled = !ModelController.shared._isUpdatingData.value
        self.showShopVC(vc, shop: shop, favoritesButton: isEnabled)
      })
      .disposed(by: disposeBag)
    
    showShopVC
      .map { _ in }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: self.commitChanges)
      .disposed(by: disposeBag)
  }
}

  // MARK: - Setup Image
extension FavoritesViewModel {
  
  func setupPreviewImage(for shop: ShopData) -> Completable {
    return ModelController.shared.setupPreviewImage(for: shop)
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

  // MARK: - Performing Search
extension FavoritesViewModel {
  
  private func buildTrie(with shops: [ShopData]) {
    let trie = Trie<String>()
    
    shops.forEach { shop in
      trie.insert(shop.name.lowercased(), shop: shop)
      
      shop.tags.forEach { tag in
        trie.insert(tag, shop: shop)
      }
    }
    
    self.trie.accept(trie)
  }
  
  private func filteredCategories(with filter: String) -> [ShopCategoryData] {
    
    let categories = segmentIndex.value == 0 ? model.currentCollectionsBySections : model.currentCollectionsByDates
    
    if filter.isEmpty {
      return categories
    }
    
    let lowercasedFilter = filter.lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
    
    let filteredShops = self.trie.value.collections(startingWith: lowercasedFilter)
    
    let filtered = categories.reduce(into: [ShopCategoryData]()) { result, category in
      let shops = filteredShops.filter { shop in
        guard let categoryName = shop.category?.categoryName else { return false }
        
        return categoryName == category.categoryName
      }
      
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
 
  private func showShopVC(_ vc: UIViewController, shop: ShopData, favoritesButton: Bool) {
    guard let category = shop.category else { return }
    navigator.showShopVC(sender: vc, section: category, shop: shop, favoritesButton: favoritesButton)
  }
}
