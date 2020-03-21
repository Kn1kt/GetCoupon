//
//  ShopViewModel.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 12.03.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ShopViewModel {
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private var navigator: Navigator!
  
  private let section: BehaviorRelay<ShopCategoryData>!
  
  // MARK: - Input
  let controllerWillDisappear = PublishRelay<Void>()
  
  let shopIsFavoriteChanged = PublishRelay<Void>()
  
  let websiteButton = PublishRelay<Void>()
  
  // MARK: - Output
  private let _shop: BehaviorRelay<ShopData>!
  
  var shop: Driver<ShopData> {
    return _shop
      .asDriver()
  }
  
  var currentShop: ShopData {
    return _shop.value
  }
  
  // MARK: - Init
  init(navigator: Navigator,
       section: ShopCategoryData,
       shop: ShopData) {
    self.navigator = navigator
    
    self._shop = BehaviorRelay<ShopData>(value: shop)
    self.section = BehaviorRelay<ShopCategoryData>(value: section)
    
    bindOutput()
    bindActions()
  }
  
  private func bindOutput() {

  }
  
  private func bindActions() {
    
    let shopDidEdit = shopIsFavoriteChanged
      .scan(false) { prev, _ in
        return !prev
    }
    
    controllerWillDisappear
      .observeOn(defaultScheduler)
      .bind(to: shopIsFavoriteChanged)
      .disposed(by: disposeBag)
    
    controllerWillDisappear
      .withLatestFrom(shopDidEdit)
      .filter { $0 }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .subscribe(onNext: { [unowned self] _ in
//        guard let self = self else { return }
//        print("isChanged run")
        ModelController.shared.updateFavoritesCategory(self.section.value, shop: self.currentShop)
      })
      .disposed(by: disposeBag)
    
    controllerWillDisappear
      .withLatestFrom(shopDidEdit)
      .filter { $0 }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [unowned self] _ in
//        guard let self = self else { return }
        let cache = CacheController()
        cache.shop(with: self.currentShop.name,
                   isFavorite: self.currentShop.isFavorite,
                   date: self.currentShop.favoriteAddingDate)
      })
      .disposed(by: disposeBag)

    websiteButton
      .withLatestFrom(_shop)
      .subscribeOn(eventScheduler)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] shop in
        self.openWebsite(shop: shop)
      })
      .disposed(by: disposeBag)
  }
}

  // MARK: - Setup Images
extension ShopViewModel {
  
  func setupPreviewImage(for shop: ShopData) -> Completable {
    let subject = PublishSubject<Void>()
    NetworkController.shared.setupPreviewImage(in: shop) {
      subject.onCompleted()
    }
    
    return subject
      .asObservable()
      .take(1)
      .ignoreElements()
  }
  
  func setupImage(for shop: ShopData) -> Completable {
    let subject = PublishSubject<Void>()
    NetworkController.shared.setupImage(in: shop) {
      subject.onCompleted()
    }
    
    return subject
      .asObservable()
      .take(1)
      .ignoreElements()
  }
}

  // MARK: - Update Shop isFavorite property
extension ShopViewModel {
  
  func updateFavoritesStatus() {
    let shop = currentShop
    
    shop.isFavorite = !shop.isFavorite
    
    shop.favoriteAddingDate = shop.isFavorite ? Date(timeIntervalSinceNow: 0) : nil
  }
}

  //MARK: - openURL
extension ShopViewModel {
  
  func openWebsite(shop: ShopData) {
    guard let url = URL(string: shop.websiteLink) else {
      return
    }
    UIApplication.shared.open(url)
  }
}
