//
//  SearchResultsViewModel.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 25.05.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchResultsViewModel {
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private var navigator: Navigator!
  
  private let trie = BehaviorRelay<Trie<String>>(value: Trie<String>())
  
  // MARK: - Input
  let showShopVC = PublishRelay<(UIViewController, ShopData)>()
  
  let searchAttr = BehaviorRelay<(String?, [UISearchToken]?)>(value: (nil, nil))
  
  // MARK: - Output
  private let _currentCollection = BehaviorRelay<ShopCategoryData>(value: ShopCategoryData(categoryName: "Empty"))
  
  let currentCollection: Driver<ShopCategoryData>
  
  // MARK: - Init
  init() {
    self.navigator = Navigator()
    self.currentCollection = _currentCollection.asDriver()
    
    bindOutput()
    bindActions()
  }
  
  func bindOutput() {
    ModelController.shared.searchCollection
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [weak self] collection in
        guard  let self = self else { return }
        self.buildTrie(with: collection.shops)
        
        let attr = self.searchAttr.value
        self.searchAttr.accept(attr)
      })
      .disposed(by: disposeBag)
    
    searchAttr
      .skip(1)
      .observeOn(eventScheduler)
      .subscribe(onNext: { [weak self] attr in
        guard let self = self else { return }
        self._currentCollection.accept(self.filteredCategory(with: attr))
      })
      .disposed(by: disposeBag)
  }
  
  func bindActions() {
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
extension SearchResultsViewModel {
  
  func setupPreviewImage(for shop: ShopData) -> Completable {
    return ModelController.shared.setupPreviewImage(for: shop)
  }
}

  // MARK: - Show Shop View Controller
extension SearchResultsViewModel {
  
  private func showShopVC(_ vc: UIViewController, shop: ShopData, favoritesButton: Bool) {
    guard let category = shop.category else { return }
    navigator.showShopVC(sender: vc, section: category, shop: shop, favoritesButton: favoritesButton)
  }
}

  //MARK: - Performing Search
extension SearchResultsViewModel {
  
  private func buildTrie(with shops: [ShopData]) {
    let trie = Trie<String>()
    
    shops.forEach { shop in
      trie.insert(shop.name.lowercased(), shop: shop)
      
      shop.tags.forEach { tag in
        trie.insert(tag, shop: shop)
      }
      
      shop.category?.tags.forEach { tag in
        trie.insert(tag, shop: shop)
      }
    }
    
    self.trie.accept(trie)
  }
  
  private func filteredCategory(with atrr: (String?, [UISearchToken]?)) -> ShopCategoryData {
    let collection = ModelController.shared.currentSearchCollection
    guard let filter = atrr.0,
          let tokens = atrr.1 else {
      return collection
    }
    
    if filter.isEmpty && tokens.isEmpty {
      return ShopCategoryData(categoryName: "")
    }
    
    let lowercasedFilter = filter.lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
    
    let filtered: [ShopData]
    
    if lowercasedFilter.isEmpty {
      filtered = tokens
        .compactMap { (token: UISearchToken) -> Set<ShopData>? in
          guard let tokenText = token.representedObject as? String else { return nil }
          return self.trie.value[tokenText]
        }
        .reduce(Set<ShopData>()) { prev, next in
          if prev.isEmpty {
            return next
          } else {
            return prev.intersection(next)
          }
        }
        .sorted { $0.priority > $1.priority }
      
    } else if tokens.isEmpty {
      filtered = self.trie.value.collections(startingWith: lowercasedFilter)
      
    } else {
      filtered = self.trie.value.collections(startingWith: lowercasedFilter)
        .filter { shop in
          return tokens.reduce(false) { _, token in
            guard let tokenText = token.representedObject as? String,
              let category = shop.category else { return false }
            return category.tags.contains(tokenText)
          }
      }
    }
    
    return ShopCategoryData(categoryName: collection.categoryName,
                            shops: filtered,
                            tags: collection.tags)
  }
}
