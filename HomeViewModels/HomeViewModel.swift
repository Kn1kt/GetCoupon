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
  /// Receive refresh controller pull down event
  let refresh = BehaviorRelay<Bool>(value: false)
  
  let showDetailVC = PublishRelay<(ShowMoreUIButton, UIViewController)>()
  
  let showShopVC = PublishRelay<(UIViewController, ShopData)>()
  
  // MARK: - Output
  private let _collections = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  let collections: Observable<[ShopCategoryData]>
  
  /// Current status of refresh controller
  private let isRefreshing = BehaviorRelay<Bool>(value: true)
  
  /// Send to refresh controller terminating events
  private let _endRefreshing: BehaviorRelay<Bool>!
  
  let endRefreshing: Driver<Bool>
  
  // MARK: - Init
  init() {
    self.model = ModelController.shared.homeDataController
    self.navigator = Navigator()
    
    self.collections = _collections.share(replay: 1)
    
    let forceUpdating = UserDefaults.standard.bool(forKey: UserDefaultKeys.forceCatalogUpdating.rawValue)
    _endRefreshing = BehaviorRelay<Bool>(value: forceUpdating)
    
    self.endRefreshing = _endRefreshing.asDriver()
    
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
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] (button, vc) in
        self.showDetailVC(button, vc: vc)
      })
      .disposed(by: disposeBag)
    
    showShopVC
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] (vc, shop) in
        let isEnabled = !self.isRefreshing.value
        self.showShopVC(vc, shop: shop, favoritesButton: isEnabled)
      })
      .disposed(by: disposeBag)
  }
}

  // MARK: - Setup Image
extension HomeViewModel {
  
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

  // MARK: - Show Home Detail View Controller
extension HomeViewModel {
  
  private func showDetailVC(_ sender: ShowMoreUIButton, vc: UIViewController) {
    guard let sectionIndex = sender.sectionIndex,
          let section = model.section(for: sectionIndex) else { return }
    
    navigator.showHomeDetailVC(sender: vc,
                               model: model,
                               section: section)
  }
}
  // MARK: - Show Shop View Controller
extension HomeViewModel {
  
  private func showShopVC(_ vc: UIViewController, shop: ShopData, favoritesButton: Bool) {
    guard let category = shop.category else { return }
    navigator.showShopVC(sender: vc, section: category, shop: shop, favoritesButton: favoritesButton)
  }
}
