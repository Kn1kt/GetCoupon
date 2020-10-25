//
//  HomeDetailViewModel.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 08.03.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeDetailViewModel {
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private var navigator: Navigator!
  private var model: HomeDataController!
  
  private let section: BehaviorRelay<ShopCategoryData>!
  private let sectionByDates: BehaviorRelay<ShopCategoryData>!
  
  private let trie = BehaviorRelay<Trie<String>>(value: Trie<String>())
  
  // MARK: - Input
  let segmentIndex = BehaviorRelay<Int>(value: 0)
  
  let searchText = BehaviorRelay<String>(value: "")
  
  let editedShops = PublishRelay<ShopData>()
  
  let controllerWillDisappear = PublishRelay<Void>()
  
  let showShopVC = PublishRelay<(UIViewController, ShopData)>()
  
  // MARK: - Output
  private let _currentSection: BehaviorRelay<ShopCategoryData>!
  
  let currentSection: Driver<ShopCategoryData>
  
  let isUpdatingData: Driver<Bool>
  
  let title: Driver<String>
  
  private let _favoritesUpdates =  PublishRelay<Void>()
  
  let favoritesUpdates: Signal<Void>
  
  // MARK: - Init
  init(navigator: Navigator,
       model: HomeDataController,
       section: Observable<ShopCategoryData>) {
    self.navigator = navigator
    self.model = model
    
    self.section = BehaviorRelay<ShopCategoryData>(value: ShopCategoryData(categoryName: ""))
    self.sectionByDates = BehaviorRelay<ShopCategoryData>(value: ShopCategoryData(categoryName: ""))
    
    self._currentSection = BehaviorRelay<ShopCategoryData>(value: ShopCategoryData(categoryName: ""))
    
    self.currentSection = _currentSection.asDriver()
    
    self.isUpdatingData = ModelController.shared.isUpdatingData.asDriver(onErrorJustReturn: false)
    
    self.favoritesUpdates = _favoritesUpdates.asSignal()
    
    self.title = section
      .map { section in
        return section.categoryName
      }
      .asDriver(onErrorJustReturn: "")
    
    section
      .observeOn(defaultScheduler)
      .bind(to: self.section)
      .disposed(by: disposeBag)
    
    bindOutput()
    bindActions()
  }
  
  private func bindOutput() {
    let section = self.section.share(replay: 1)
    
    section
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [weak self] collection in
        guard let self = self else { return }
        self.buildTrie(with: collection.shops)
        
        let searchText = self.searchText.value
        if !searchText.isEmpty {
          self.searchText.accept(searchText)
          return
        }
        
        let segmentIndex = self.segmentIndex.value
        self.segmentIndex.accept(segmentIndex)
      })
      .disposed(by: disposeBag)
    
    section
      .observeOn(defaultScheduler)
      .map { category in
        return ShopCategoryData(categoryName: category.categoryName,
                                shops: category.shops.sorted { lhs, rhs in
                                  if let lhsDate = lhs.promoCodes.first?.addingDate {
                                    if let rhsDate = rhs.promoCodes.first?.addingDate {
                                      return lhsDate > rhsDate
                                    }
                                    
                                    return true
                                  }
                                  
                                  return false
          },
                                tags: category.tags)
      }
      .bind(to: sectionByDates)
      .disposed(by: disposeBag)
    
    let segmentIndex = self.segmentIndex.share(replay: 1)
    
    segmentIndex
      .observeOn(eventScheduler)
      .filter { [weak self] _ in
        guard let self = self else { fatalError("SegmentIndexFilter") }
        return self.searchText.value.isEmpty
      }
      .map { [weak self] (index: Int) -> ShopCategoryData in
        guard let self = self else { fatalError("SegmentIndexMap") }
        
        switch index {
        case 1:
          return self.sectionByDates.value
        default:
          return self.section.value
        }
      }
      .bind(to: _currentSection)
      .disposed(by: disposeBag)
    
    searchText
      .skip(1)
      .observeOn(eventScheduler)
      .subscribe(onNext: { [weak self] text in
        guard let self = self else { return }
        self._currentSection.accept(self.filteredCategory(with: text))
      })
      .disposed(by: disposeBag)
    
    ModelController.shared.favoriteCollections
      .skip(1)
      .observeOn(eventScheduler)
      .map { _ in }
      .bind(to: _favoritesUpdates)
      .disposed(by: disposeBag)
    
    ModelController.shared.sceneWillResignActive
      .observeOn(eventScheduler)
      .bind(to: controllerWillDisappear)
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
    
    let controllerWillDisappear = self.controllerWillDisappear.share(replay: 1)
    
    controllerWillDisappear
      .withLatestFrom(unicEditedShops)
      .observeOn(eventScheduler)
      .filter { !$0.isEmpty }
      .map { shops in shops.filter { $0.isFavorite } }
      .subscribe(onNext: { [weak self] shops in
        guard let self = self else { return }
        self.model.updateFavoritesCategory(self.section.value, shops: shops)
        unicEditedShops.accept([])
      })
      .disposed(by: disposeBag)
    
    controllerWillDisappear
      .withLatestFrom(unicEditedShops)
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
    
    showShopVC
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] (vc, shop) in
        let isEnabled = !ModelController.shared._isUpdatingData.value
        self.showShopVC(vc, shop: shop, favoritesButton: isEnabled)
      })
      .disposed(by: disposeBag)
  }
}

  // MARK: - Setup Image
extension HomeDetailViewModel {
  
  func setupPreviewImage(for shop: ShopData) -> Completable {
    return ModelController.shared.setupPreviewImage(for: shop)
  }
}

  // MARK: - Update Shop isFavorite property
extension HomeDetailViewModel {
  
  func updateFavorites(_ sender: AddToFavoritesButton) {
    guard let shop = sender.cell else { return }
    
    shop.isFavorite = !shop.isFavorite
    
    shop.favoriteAddingDate = shop.isFavorite ? Date(timeIntervalSinceNow: 0) : nil
  }
}

  //MARK: - Performing Search
extension HomeDetailViewModel {
  
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
  
  private func filteredCategory(with filter: String) -> ShopCategoryData {
    
    let lowercasedFilter = filter.lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
    
    if lowercasedFilter.isEmpty {
      return segmentIndex.value == 0 ? section.value : sectionByDates.value
    }
    
    let filtered = self.trie.value.collections(startingWith: lowercasedFilter)
    
    return ShopCategoryData(categoryName: section.value.categoryName,
                            shops: filtered,
                            tags: section.value.tags)
  }
}

  // MARK: - Show Shop View Controller
extension HomeDetailViewModel {
  
  private func showShopVC(_ vc: UIViewController, shop: ShopData, favoritesButton: Bool) {
    guard let category = shop.category else { return }
    navigator.showShopVC(sender: vc, section: category, shop: shop, favoritesButton: favoritesButton)
  }
}
