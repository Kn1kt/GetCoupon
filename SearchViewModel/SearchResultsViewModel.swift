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

class SearchResultsViewModel: SearchViewModel {
  
  // MARK: - Input
  let searchText = BehaviorRelay<String>(value: "")
  
  let showSuggestedSearches = BehaviorRelay<Bool>(value: true)
  
  // MARK: - Output
  private let suggestedSearches = BehaviorRelay<[String : [ShopData]]>(value: [:])
  
  var suggestedSearchesList: Driver<SuggestedSearchCategoryData>!
  
  // MARK: - Init
  override func bindOutput() {
    ModelController.shared.searchCollection
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [weak self] collection in
        guard  let self = self else { return }

        let searchText = self.searchText.value
        if !searchText.isEmpty {
          self.searchText.accept(searchText)

        } else {
          self._currentCollection.accept(collection)
        }
      })
      .disposed(by: disposeBag)
    
    ModelController.shared.searchCollection
      .map { collection in
        collection.shops.reduce(into: [String : [ShopData]]()) { result, shop in
          guard let category = shop.category else { return }
// TODO: Reduce count of tags
          category.tags.forEach { tag in
            result[tag, default: []].append(shop)
          }
        }
      }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: suggestedSearches)
      .disposed(by: disposeBag)
    
    self.suggestedSearchesList = suggestedSearches
      .map { dict in
        let list = SuggestedSearchCategoryData(title: "Trending",
                                               tokens: dict.keys.map { SuggestedSearchCellData(tokenText: $0) })
        return list
      }
      .subscribeOn(defaultScheduler)
      .asDriver(onErrorJustReturn: SuggestedSearchCategoryData(title: "Empty", tokens: []))
    
    searchText
      .skip(1)
      .map { [weak self] (text: String) -> ShopCategoryData in
        guard let self = self else { fatalError("searchText") }
        return self.filteredCategory(with: text)
      }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: _currentCollection)
      .disposed(by: disposeBag)
  }
}

  //MARK: - Performing Search
extension SearchResultsViewModel {
  
  private func filteredCategory(with filter: String) -> ShopCategoryData {
    let collection = ModelController.shared.currentSearchCollection
    
    if filter.isEmpty {
      return ShopCategoryData(categoryName: "")
    }
    
    let lowercasedFilter = filter.lowercased()
    
    let filtered = collection.shops
        .filter { shop in
          return shop.name.lowercased().contains(lowercasedFilter)
            || shop.category?.tags.contains(lowercasedFilter) ?? false
        }
        .sorted { $0.name < $1.name }
      
      return ShopCategoryData(categoryName: collection.categoryName,
                              shops: filtered,
                              tags: collection.tags)
  }
}
