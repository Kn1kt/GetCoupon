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
  
  private let suggestedSearches = BehaviorRelay<[String : [ShopData]]>(value: [:])
  
  // MARK: - Input
  let selectedToken = PublishRelay<String>()
  
  // MARK: - Output
  var suggestedSearchesList: Driver<SuggestedSearchCategoryData>!
  
  private let _insertToken = PublishRelay<UISearchToken>()
  
  var insertToken: Driver<UISearchToken>!
  // MARK: - Init
  init() {
    self.insertToken = _insertToken.asDriver(onErrorJustReturn: UISearchToken(icon: nil, text: ""))
    
    bindOutput()
    bindActions()
  }
  
  func bindOutput() {
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
        SuggestedSearchCategoryData(title: "Trending",
                                    tokens: dict.keys.map { SuggestedSearchCellData(tokenText: $0) })
      }
      .subscribeOn(defaultScheduler)
      .asDriver(onErrorJustReturn: SuggestedSearchCategoryData(title: "Empty", tokens: []))
  }
  
  func bindActions() {
    selectedToken
      .map { tokenText in
        let token = UISearchToken(icon: nil, text: tokenText)
        token.representedObject = tokenText
        return token
      }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: _insertToken)
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

  // MARK: - Provide Search Tokens
extension SearchViewModel {
    func replacedTokens(_ textField: UISearchTextField?) -> Bool {
      guard let textField = textField,
            let filter = textField.text else {
        return false
      }
  
      let lowercasedFilter = filter.lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
      if let _ = suggestedSearches.value[lowercasedFilter] {
        let token = UISearchToken(icon: nil, text: lowercasedFilter)
        token.representedObject = lowercasedFilter
        textField.replaceTextualPortion(of: textField.textualRange, with: token, at: textField.tokens.count)
  
        return true
      } else {
        return false
      }
    }
}
