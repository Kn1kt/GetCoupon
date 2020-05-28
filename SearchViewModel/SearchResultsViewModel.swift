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
  
//  private let suggestedSearches = BehaviorRelay<[String : [ShopData]]>(value: [:])
  
//  private let performSearch = PublishRelay<(String?, [UISearchToken]?)>()
  
  // MARK: - Input
  let showShopVC = PublishRelay<(UIViewController, ShopData)>()
  
  let searchAtrr = BehaviorRelay<(String?, [UISearchToken]?)>(value: (nil, nil))
  
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

        let atrr = self.searchAtrr.value
        self.searchAtrr.accept(atrr)
      })
      .disposed(by: disposeBag)
    
//    ModelController.shared.searchCollection
//      .map { collection in
//        collection.shops.reduce(into: [String : [ShopData]]()) { result, shop in
//          guard let category = shop.category else { return }
//// TODO: Reduce count of tags
//          category.tags.forEach { tag in
//            result[tag, default: []].append(shop)
//          }
//        }
//      }
//      .subscribeOn(defaultScheduler)
//      .observeOn(defaultScheduler)
//      .bind(to: suggestedSearches)
//      .disposed(by: disposeBag)
    
    searchAtrr
      .skip(1)
      .map { [weak self] (attr: (String?, [UISearchToken]?)) -> ShopCategoryData in
        guard let self = self else { fatalError("searchText") }
        return self.filteredCategory(with: attr)
      }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: _currentCollection)
      .disposed(by: disposeBag)
    
//    searchText
//      .skip(1)
//      .filter { [weak self] textField in
//        guard let self = self else { return false }
//        return !self.replacedTokens(textField)
//      }
//      .map { textField in
//        let text = textField?.text
//        let tokens = textField?.tokens
//        return (text, tokens)
//      }
//      .subscribeOn(MainScheduler.instance)
//      .observeOn(eventScheduler)
//      .bind(to: performSearch)
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
extension SearchResultsViewModel {
  
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

  // MARK: - Show Shop View Controller
extension SearchResultsViewModel {
  
  private func showShopVC(_ vc: UIViewController, shop: ShopData) {
    guard let category = shop.category else { return }
    navigator.showShopVC(sender: vc, section: category, shop: shop)
  }
}

  //MARK: - Performing Search
extension SearchResultsViewModel {
  
//  func replacedTokens(_ textField: UISearchTextField?) -> Bool {
//    guard let textField = textField,
//          let filter = textField.text else {
//      return false
//    }
//
//    let lowercasedFilter = filter.lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
//    if let _ = suggestedSearches.value[lowercasedFilter] {
//      let token = UISearchToken(icon: nil, text: lowercasedFilter)
//      token.representedObject = lowercasedFilter
//      textField.replaceTextualPortion(of: textField.textualRange, with: token, at: textField.tokens.count)
//
//      return true
//    } else {
//      return false
//    }
//  }
  
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
    
    let filtered = collection.shops
        .filter { shop in
          let contains = shop.name.lowercased().contains(lowercasedFilter)
          if tokens.isEmpty {
            return contains
            
          } else if lowercasedFilter.isEmpty {
            return tokens.reduce(false) { _, token in
              guard let tokenText = token.representedObject as? String,
                let category = shop.category else { return false }
              return category.tags.contains(tokenText)
            }
            
          } else if contains {
            return tokens.reduce(false) { _, token in
              guard let tokenText = token.representedObject as? String,
                let category = shop.category else { return false }
              return category.tags.contains(tokenText)
            }
            
          } else {
            return false
          }
        }
        .sorted { $0.name < $1.name }
      
      return ShopCategoryData(categoryName: collection.categoryName,
                              shops: filtered,
                              tags: collection.tags)
  }
}
