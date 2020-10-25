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
  
  private let sectionWithTitles = BehaviorRelay<[String : Int]>(value: [:])
  
  func section(for title: String) -> Observable<ShopCategoryData>? {
    guard let sectionIndex = sectionWithTitles.value[title] else { return nil }
    
    return ModelController.shared.section(for: sectionIndex)
  }
  
  init(collections: Observable<[ShopCategoryData]>, advData: Observable<[AdvertisingCategoryData]>) {
    self.collections = _collections.share(replay: 1)
    self.advEnabled = _advEnabled.share(replay: 1)
    self.advSections = _advSections.share(replay: 1)
    
    collections
      .observeOn(defaultScheduler)
      .map { _ in false }
      .bind(to: _advEnabled)
      .disposed(by: disposeBag)
    
    collections
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [weak self] collections in
        guard let self = self else { return }
        let sectionWithTitles = collections.enumerated().reduce(into: [String : Int]()) { result, section in
          guard section.element.categoryName != "AdvertisingCategoryData" else { return }
          result[section.element.categoryName] = section.offset
        }
        
        self.sectionWithTitles.accept(sectionWithTitles)
      })
      .disposed(by: disposeBag)
    
    collections
      .observeOn(defaultScheduler)
      .map { (collections: [ShopCategoryData]) -> [ShopCategoryData] in
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
      .observeOn(defaultScheduler)
      .filter { !$0.isEmpty }
      .subscribe(onNext: { [weak self] advData in
        guard let self = self,
              !self._advEnabled.value else { return }
        
        var collections = self._collections.value
        var advSections = Set<Int>()
        
        advData.enumerated().forEach { n, advSection in
          let index = advSection.linkedSection + 1 + n
          let correctedIndex = index > collections.endIndex ? collections.endIndex : index
          
          advSections.insert(correctedIndex)
          
          let castedSection = ShopCategoryData(categoryName: "AdvertisingCategoryData",
                                               shops: advSection.adsList
                                                .sorted { $0.priority > $1.priority }
                                                .map { advCell in
                                                  return ShopData(name: "AdvertisingCell",
                                                                  shortDescription: "AdvertisingCell",
                                                                  websiteLink: advCell.websiteLink,
                                                                  previewImageLink: advCell.imageLink)
                                                })
          
          collections.insert(castedSection, at: correctedIndex)
        }
        self._advSections.accept(advSections)
        self._advEnabled.accept(true)
        self._collections.accept(collections)
        print("INSERTED")
      })
      .disposed(by: disposeBag)
  }
}
