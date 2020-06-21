//
//  HomeDataController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HomeDataController {
  
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let disposeBag = DisposeBag()
  
  private let _collections = BehaviorRelay<[ShopCategoryData]>(value: [])
  let collections: Observable<[ShopCategoryData]>
  
  private let _advEnabled =  BehaviorRelay<Bool>(value: false)
  let advEnabled: Observable<Bool>
  
  private let _advSections = BehaviorRelay<Set<Int>>(value: Set<Int>())
  let advSections: Observable<Set<Int>>
  
  func section(for index: Int) -> Observable<ShopCategoryData>? {
    return ModelController.shared.section(for: index)
  }
  
  func category(for shop: ShopData) -> ShopCategoryData {
    guard let category = _collections.value.first(where: { $0.shops.contains(shop) }) else {
      fatalError("No category")
    }
    
    return category
  }
  
  init(collections: Observable<[ShopCategoryData]>, advData: Observable<[AdvertisingCategoryData]>) {
    self.collections = _collections.share(replay: 1)
    self.advEnabled = _advEnabled.share(replay: 1)
    self.advSections = _advSections.share(replay: 1)
    
    collections
      .map { _ in false }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: _advEnabled)
      .disposed(by: disposeBag)
    
    collections.map { (collections: [ShopCategoryData]) -> [ShopCategoryData] in
      return collections.map { category in
        return ShopCategoryData(categoryName: category.categoryName,
                                shops: Array(category.shops
                                  .sorted(by: { lhs, rhs in
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
                                  .prefix(10)),
                                tags: category.tags)
      }
    }
    .subscribeOn(defaultScheduler)
    .observeOn(defaultScheduler)
    .bind(to: _collections)
    .disposed(by: disposeBag)
    
    embedAdv(advData)
  }
}

  // MARK: - Favorites Updates
extension HomeDataController {
  
  func updateFavoritesCategory(_ category: ShopCategoryData, shops: Set<ShopData>) {
    ModelController.shared.updateFavoritesCategory(category, shops: shops)
  }
}

  // MARK: - Advertising Embedding
extension HomeDataController {
  
  private func embedAdv(_ advData: Observable<[AdvertisingCategoryData]>) {
    advData
//      .delay(.seconds(2), scheduler: defaultScheduler)
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [weak self] advData in
        guard let self = self,
          !self._advEnabled.value else { return }
        
        var collections = self._collections.value
        var advSections = Set<Int>()
        
        advData.forEach { advSection in
          advSections.insert(advSection.linkedSection + 1)
          
          let castedSection = ShopCategoryData(categoryName: "AdvertisingCategoryData",
                                               shops: advSection.adsList.map { advCell in
                                                return ShopData(name: "AdvertisingCell",
                                                                shortDescription: "AdvertisingCell",
                                                                websiteLink: advCell.websiteLink,
                                                                previewImageLink: advCell.imageLink)
          })
          collections.insert(castedSection, at: advSection.linkedSection + 1)
        }
        self._advSections.accept(advSections)
        self._advEnabled.accept(true)
        self._collections.accept(collections)
        print("INSERTED")
      })
      .disposed(by: disposeBag)
  }
}
