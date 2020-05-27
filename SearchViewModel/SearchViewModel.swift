//
//  SearchViewModel.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.03.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewModel {
  
  let disposeBag = DisposeBag()
  let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private var navigator: Navigator!
  
  // MARK: - Input
//  let searchText = BehaviorRelay<String>(value: "")
  
  let showShopVC = PublishRelay<(UIViewController, ShopData)>()
  
  // MARK: - Output
  let _currentCollection = BehaviorRelay<ShopCategoryData>(value: ShopCategoryData(categoryName: "Empty"))
  
  let currentCollection: Driver<ShopCategoryData>
  
  private let _isRefreshing = BehaviorRelay<Bool>(value: true)
  
  let isRefreshing: Driver<Bool>
  
  // MARK: - Init
  init() {
    self.navigator = Navigator()
    
    self.currentCollection = _currentCollection.asDriver()
    self.isRefreshing = _isRefreshing.asDriver()
    
    bindOutput()
    bindActions()
  }
  
  func bindOutput() {
    ModelController.shared.searchCollection
      .observeOn(defaultScheduler)
//      .subscribe(onNext: { [weak self] collection in
//        guard  let self = self else { return }
//
//        let searchText = self.searchText.value
//        if !searchText.isEmpty {
//          self.searchText.accept(searchText)
//
//        } else {
//          self._currentCollection.accept(collection)
//        }
//      })
      .bind(to: _currentCollection)
      .disposed(by: disposeBag)
    
//    searchText
//      .skip(1)
//      .map { [weak self] (text: String) -> ShopCategoryData in
//        guard let self = self else { fatalError("searchText") }
//        return self.filteredCategory(with: text)
//      }
//      .subscribeOn(eventScheduler)
//      .observeOn(eventScheduler)
//      .bind(to: _currentCollection)
//      .disposed(by: disposeBag)
  }
  
  func bindActions() {
    showShopVC
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] (vc, shop) in
        self.showShopVC(vc, shop: shop)
      })
      .disposed(by: disposeBag)
  }
}

  // MARK: - Setup Image
extension SearchViewModel {
  
  func setupImage(for shop: ShopData) -> Completable {
    let subject = PublishSubject<Void>()
    NetworkController.shared.setupPreviewImage(in: shop) {
      if let _ = shop.previewImage {
        subject.onCompleted()
      } else {
        guard let category = shop.category else {
          subject.onCompleted()
          return
        }
        NetworkController.shared.setupDefaultImage(in: category) {
          shop.previewImage = category.defaultImage
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

//  //MARK: - Performing Search
//extension SearchViewModel {
//  
//  private func filteredCategory(with filter: String) -> ShopCategoryData {
//    let collection = ModelController.shared.currentSearchCollection
//    
//    if filter.isEmpty {
//      return ShopCategoryData(categoryName: "")
//    }
//    
//    let lowercasedFilter = filter.lowercased()
//    
//    let filtered = collection.shops
//        .filter { shop in
//          return shop.name.lowercased().contains(lowercasedFilter)
//            || shop.category?.tags.contains(lowercasedFilter) ?? false
//        }
//        .sorted { $0.name < $1.name }
//      
//      return ShopCategoryData(categoryName: collection.categoryName,
//                              shops: filtered,
//                              tags: collection.tags)
//  }
//}

  // MARK: - Show Shop View Controller
extension SearchViewModel {
  
  private func showShopVC(_ vc: UIViewController, shop: ShopData) {
    guard let category = shop.category else { return }
    navigator.showShopVC(sender: vc, section: category, shop: shop)
  }
}
