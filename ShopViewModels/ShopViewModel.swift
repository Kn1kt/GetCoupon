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
  
  let favoriteButtonEnabled: Driver<Bool>
  
  private let _shop: BehaviorRelay<ShopData>!
  
  let shop: Driver<ShopData>
  
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
    ModelController.shared.isUpdatingData
      .observeOn(defaultScheduler)
      .filter { $0 }
      .map { _ in false }
      .take(1)
      .bind(to: _favoriteButtonEnabled)
      .disposed(by: disposeBag)
    
    ModelController.shared.sceneWillResignActive
      .observeOn(eventScheduler)
      .bind(to: controllerWillDisappear)
      .disposed(by: disposeBag)
  }
  
  private func bindActions() {
    
    let shopDidEdit = shopIsFavoriteChanged
      .scan(false) { prev, _ in
        return !prev
      }
      .share()
    
    controllerWillDisappear
      .withLatestFrom(shopDidEdit)
      .observeOn(eventScheduler)
      .filter { $0 }
      .subscribe(onNext: { [unowned self] _ in
        ModelController.shared.updateFavoritesCategory(self.section.value, shop: self.currentShop)
        self.shopIsFavoriteChanged.accept(())
      })
      .disposed(by: disposeBag)
    
    controllerWillDisappear
      .withLatestFrom(shopDidEdit)
      .observeOn(defaultScheduler)
      .filter { $0 }
      .subscribe(onNext: { [unowned self] _ in
        let cache = CacheController()
        cache.shop(with: self.currentShop.name,
                   isFavorite: self.currentShop.isFavorite,
                   date: self.currentShop.favoriteAddingDate)
      })
      .disposed(by: disposeBag)

    websiteButton
      .withLatestFrom(_shop)
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
    return ModelController.shared.setupPreviewImage(for: shop)
  }
  
  func setupImage(for shop: ShopData) -> Completable {
    return ModelController.shared.setupImage(for: shop)
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

  // MARK: - openURL
extension ShopViewModel {
  
  func openWebsite(shop: ShopData) {
    guard let url = URL(string: shop.websiteLink) else {
      return
    }
    UIApplication.shared.open(url)
  }
}

  // MARK: - Building Share Text
extension ShopViewModel {
  
  func buildShareText(for shop: ShopData, coupon: PromoCodeData?) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    
    var promoString = "👋 Привет!\n\nВ \(shop.name) "
    
    if let coupon = coupon {
      promoString += "до \(dateFormatter.string(from: coupon.estimatedDate)) "
      
      promoString += "действует \(coupon.coupon)"
      
      promoString += ":\n\(coupon.description)\n"
    } else {
      let coupons = shop.promoCodes
        .prefix(3)
        .map { coupon in
          return "🔥 \(coupon.coupon): \(coupon.description)"
        }
        .joined(separator: "\n\n")
      
      promoString += "сейчас действуют:\n\(coupons)\n"
    }
    
    promoString += "\n🚀 Подробности можешь узнать в GetCoupon"
    
    return promoString
  }
}
