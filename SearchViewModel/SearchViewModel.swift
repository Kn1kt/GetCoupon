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
  
  private let suggestedSearches = BehaviorRelay<[String : Int]>(value: [:])
  
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
      .observeOn(defaultScheduler)
      .map { collection in
        collection.shops.reduce(into: [String : Int]()) { result, shop in
          guard let category = shop.category else { return }
          category.tags.forEach { tag in
            result[tag, default: 0] += 1
          }
        }
      }
      .bind(to: suggestedSearches)
      .disposed(by: disposeBag)
    
    self.suggestedSearchesList = suggestedSearches
      .asObservable()
      .observeOn(defaultScheduler)
      .map { dict in
        let popularTags = dict.keys
          .sorted { lhs, rhs in
            return dict[lhs]! > dict[rhs]!
          }
          .prefix(10)
          .map { SuggestedSearchCellData(tokenText: $0) }
        
        return SuggestedSearchCategoryData(title: "Trending", tokens: popularTags)
      }
      .asDriver(onErrorJustReturn: SuggestedSearchCategoryData(title: "Empty", tokens: []))
  }
  
  func bindActions() {
    selectedToken
      .observeOn(eventScheduler)
      .map { tokenText in
        let token = UISearchToken(icon: nil, text: tokenText)
        token.representedObject = tokenText
        return token
      }
      .bind(to: _insertToken)
      .disposed(by: disposeBag)
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
