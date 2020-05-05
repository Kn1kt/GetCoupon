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
  
  private let _favoriteButtonEnabled: BehaviorRelay<Bool>!
  
  let favoriteButtonEnabled: Driver<Bool>// {
//    return _favoriteButtonEnabled
//      .asDriver()
//  }
  
  private let _shop: BehaviorRelay<ShopData>!
  
  let shop: Driver<ShopData> //{
//    return _shop
//      .asDriver()
//  }
  
  var currentShop: ShopData {
    return _shop.value
  }
  
  // MARK: - Init
  init(navigator: Navigator,
       section: ShopCategoryData,
       shop: ShopData,
       favoriteButtonEnabled: Bool) {
    self.navigator = navigator
    
    self._shop = BehaviorRelay<ShopData>(value: shop)
    self.shop = _shop.asDriver()
    self.section = BehaviorRelay<ShopCategoryData>(value: section)
    self._favoriteButtonEnabled = BehaviorRelay<Bool>(value: favoriteButtonEnabled)
    self.favoriteButtonEnabled = _favoriteButtonEnabled.asDriver()
    
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
      .share()
    
    controllerWillDisappear
      .withLatestFrom(shopDidEdit)
      .filter { $0 }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .subscribe(onNext: { [unowned self] _ in
        ModelController.shared.updateFavoritesCategory(self.section.value, shop: self.currentShop)
        self.shopIsFavoriteChanged.accept(())
      })
      .disposed(by: disposeBag)
    
    controllerWillDisappear
      .withLatestFrom(shopDidEdit)
      .filter { $0 }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [unowned self] _ in
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
      if let _ = shop.previewImage {
        subject.onCompleted()
      } else {
        NetworkController.shared.setupDefaultImage(in: shop.category) {
          shop.previewImage = shop.category.defaultImage
          subject.onCompleted()
        }
      }
    }
    
    return subject
      .asObservable()
      .take(1)
      .ignoreElements()
  }
  
  func setupImage(for shop: ShopData) -> Completable {
    let subject = PublishSubject<Void>()
    NetworkController.shared.setupImage(in: shop) {
      if let _ = shop.image {
        subject.onCompleted()
      } else {
        NetworkController.shared.setupDefaultImage(in: shop.category) {
          shop.image = shop.category.defaultImage
          subject.onCompleted()
        }
      }
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
