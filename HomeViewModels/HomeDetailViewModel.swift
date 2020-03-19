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
  
  // MARK: - Input
  let segmentIndex = BehaviorRelay<Int>(value: 0)
  
  let searchText = BehaviorRelay<String>(value: "")
  
  let editedShops = PublishRelay<ShopData>()
  
  let controllerWillDisappear = PublishRelay<Void>()
  
  let showShopVC = PublishRelay<(UIViewController, ShopData)>()
  
  // MARK: - Output
  private let _currentSection: BehaviorRelay<ShopCategoryData>!
  
  var currentSection: Driver<ShopCategoryData> {
    return _currentSection
      .asDriver()
  }
  
  private let _favoritesUpdates =  PublishRelay<Void>()
  
  var favoritesUpdates: Signal<Void> {
    return _favoritesUpdates.asSignal()
  }
  
  // MARK: - Init
  init(navigator: Navigator,
       model: HomeDataController,
       section: Observable<ShopCategoryData>) {
    self.navigator = navigator
    self.model = model
    
    self.section = BehaviorRelay<ShopCategoryData>(value: ShopCategoryData(categoryName: "Empty"))
    self.sectionByDates = BehaviorRelay<ShopCategoryData>(value: ShopCategoryData(categoryName: "Empty"))
    
    self._currentSection = BehaviorRelay<ShopCategoryData>(value: ShopCategoryData(categoryName: "Empty"))
    
    section
      .observeOn(defaultScheduler)
      .bind(to: self.section)
      .disposed(by: disposeBag)
    
    bindOutput()
    bindActions()
  }
  
  private func bindOutput() {
    section
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
    
    section
      .map { category in
        return ShopCategoryData(categoryName: category.categoryName,
                                shops: category.shops.shuffled(),
                                tags: category.tags)
      }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: sectionByDates)
      .disposed(by: disposeBag)
    
    segmentIndex
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
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: _currentSection)
      .disposed(by: disposeBag)
    
    searchText
      .skip(1)
      .map { [weak self] (text: String) -> ShopCategoryData in
        guard let self = self else { fatalError("searchText") }
        return self.filteredCategory(with: text)
      }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: _currentSection)
      .disposed(by: disposeBag)
    
    ModelController.shared.favoriteCollections
      .skip(1)
      .map { _ in }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: _favoritesUpdates)
      .disposed(by: disposeBag)
  }
  
  private func bindActions() {
    let unicEditedShops = editedShops
      .scan(into: Set<ShopData>()) { result, shop in
          result.insert(shop)
      }
      .subscribeOn(defaultScheduler)
    
    controllerWillDisappear
      .withLatestFrom(unicEditedShops)
      .map { shops in shops.filter { $0.isFavorite } }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .subscribe(onNext: { [weak self] shops in
        guard let self = self else { return }
        self.model.updateFavoritesCategory(self.section.value, shops: shops)
      })
      .disposed(by: disposeBag)
    
    controllerWillDisappear
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
    
    showShopVC
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] (vc, shop) in
        self.showShopVC(vc, section: self.section.value, shop: shop)
      })
      .disposed(by: disposeBag)
  }
}

  // MARK: - Setup Image
extension HomeDetailViewModel {
  
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
extension HomeDetailViewModel {
  
  func updateFavorites(_ sender: AddToFavoritesButton) {
    guard let shop = sender.cell else { return }
    
    shop.isFavorite = !shop.isFavorite
    
    shop.favoriteAddingDate = shop.isFavorite ? Date(timeIntervalSinceNow: 0) : nil
  }
}

  //MARK: - Performing Search
extension HomeDetailViewModel {
  
  private func filteredCategory(with filter: String) -> ShopCategoryData {
    
    if filter.isEmpty {
      return segmentIndex.value == 0 ? section.value : sectionByDates.value
    }
    
    let lowercasedFilter = filter.lowercased()
  
    let filtered = section.value.shops
      .filter { shop in
        return shop.name.lowercased().contains(lowercasedFilter)
      }
      .sorted { $0.name < $1.name }
    
    return ShopCategoryData(categoryName: section.value.categoryName,
                            shops: filtered,
                            tags: section.value.tags)
  }
}

  // MARK: - Show Shop View Controller
extension HomeDetailViewModel {
  
  private func showShopVC(_ vc: UIViewController, section: ShopCategoryData, shop: ShopData) {
    navigator.showShopVC(sender: vc, section: section, shop: shop)
  }
}
