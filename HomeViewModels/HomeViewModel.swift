//
//  HomeViewModel.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 08.03.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewModel {
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private var navigator: Navigator!
  private var model: HomeDataController!
  
  // MARK: - Input
  let refresh = BehaviorRelay<Bool>(value: false)
  
  let showDetailVC = PublishRelay<(ShowMoreUIButton, UIViewController)>()
  
  let showShopVC = PublishRelay<(UIViewController, ShopData)>()
  
  // MARK: - Output
  private let _collections = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  var collections: Observable<[ShopCategoryData]> {
    return _collections
      .asObservable()
      .share()
  }
  
  private let isRefreshing = BehaviorRelay<Bool>(value: true)
  
  private let _endRefreshing = BehaviorRelay<Bool>(value: true)
  
  var endRefreshing: Driver<Bool> {
    return _endRefreshing
      .asDriver()
  }
  
  // MARK: - Init
  init() {
    self.model = ModelController.shared.homeDataController
    self.navigator = Navigator()
    
    bindOutput()
    bindActions()
  }
  
  private func bindOutput() {
    model.collections
      .observeOn(defaultScheduler)
      .bind(to: _collections)
      .disposed(by: disposeBag)
    
    model.collections
      .skip(1)
      .map { _ in false }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: _endRefreshing)
      .disposed(by: disposeBag)
    
    Observable
      .merge([refresh.asObservable(), _endRefreshing.asObservable()])
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: isRefreshing)
      .disposed(by: disposeBag)
  }
  
  private func bindActions() {
    refresh
      .filter { $0 }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .subscribe(onNext: { isRefreshing in
        guard isRefreshing else { fatalError("HomeViewModelRefrsh")}
        
        /* TODO:
         should fix this query
        */
        ModelController.shared.setupCollections()
      })
      .disposed(by: disposeBag)
    
    showDetailVC
//      .subscribeOn(eventScheduler)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] (button, vc) in
        self.showDetailVC(button, vc: vc)
      })
      .disposed(by: disposeBag)
    
    showShopVC
//      .subscribeOn(eventScheduler)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] (vc, shop) in
        let isEnabled = !self.isRefreshing.value
        let section = self.model.category(for: shop)
        self.showShopVC(vc, section: section, shop: shop, favoritesButton: isEnabled)
      })
      .disposed(by: disposeBag)
  }
}

  // MARK: - Setup Image
extension HomeViewModel {
  
  func setupImage(for shop: ShopData) -> Completable {
    let subject = PublishSubject<Void>()
    NetworkController.shared.setupPreviewImage(in: shop) {
      subject.onCompleted()
    }
    
    return subject
      .asObservable()
      .take(1)
      .ignoreElements()
  }
}

  // MARK: - Show Home Detail View Controller
extension HomeViewModel {
  
  private func showDetailVC(_ sender: ShowMoreUIButton, vc: UIViewController) {
    guard let sectionIndex = sender.sectionIndex else {
        return
    }
    
//    model.section(for: sectionIndex)
//      .observeOn(MainScheduler.instance)
//      .subscribe(onNext: { [unowned self] section in
//        guard let section = section else { return }
//
//        self.navigator.showHomeDetailVC(sender: vc,
//                                        model: self.model,
//                                        section: section)
//      })
//      .disposed(by: disposeBag)
    let section = model.section(for: sectionIndex)
    navigator.showHomeDetailVC(sender: vc,
                               model: model,
                               section: section)
  }
}
  // MARK: - Show Shop View Controller
extension HomeViewModel {
  
  private func showShopVC(_ vc: UIViewController, section: ShopCategoryData, shop: ShopData, favoritesButton: Bool) {
    navigator.showShopVC(sender: vc, section: section, shop: shop, favoritesButton: favoritesButton)
  }
}
