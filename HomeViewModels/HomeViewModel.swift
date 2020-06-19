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
  
  enum TitleTypes {
    case `default`(String)
    case dowloading(String)
    case downloaded(String)
    case error(String, String)
  }
  
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
  let isRefreshing = BehaviorRelay<Bool>(value: true)
  
  /// Send stopRefreshing to refresh
  let updateRefreshingStatus: Driver<Bool>
  
  let updatingTitle = BehaviorRelay<TitleTypes>(value: .default("Home"))
  
  // MARK: - Init
  init() {
    self.model = ModelController.shared.homeDataController
    self.navigator = Navigator()
    
    self.collections = _collections.share(replay: 1)
    
    self.updateRefreshingStatus = isRefreshing
      .filter { !$0 }
      .delay(.seconds(1), scheduler: eventScheduler)
      .asDriver(onErrorJustReturn: false)
    
    bindOutput()
    bindActions()
  }
  
  private func bindOutput() {
    model.collections
      .take(1)
      .observeOn(defaultScheduler)
      .bind(to: _collections)
      .disposed(by: disposeBag)
    
    model.collections
      .skip(1)
      .delay(.seconds(1), scheduler: eventScheduler)
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: _collections)
      .disposed(by: disposeBag)
    
    ModelController.shared.isUpdatingData
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: isRefreshing)
      .disposed(by: disposeBag)
    
    ModelController.shared.dataUpdatingStatus
      .map { (status: ModelController.DataStatus) -> TitleTypes in
        switch status {
        case .unknown:
          return .default("Home")
        case .updating:
          return .dowloading("Updating...")
        case .updated:
          return .downloaded("Successfully Updated")
        case .error(let e):
          return .error(String(e.localizedDescription.prefix(while: { $0 != "." })), "Update Error")
        }
      }
      .filter { status in
        switch status {
        case .downloaded(_):
          return false
        default:
          return true
        }
      }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: updatingTitle)
      .disposed(by: disposeBag)
    
    ModelController.shared.dataUpdatingStatus
      .delay(.seconds(1), scheduler: eventScheduler)
      .filter { [weak self] status in
        guard let self = self,
          self.isRefreshing.value == false else {
            return false
        }
        switch status {
        case .updated:
          return true
        default:
          return false
        }
      }
      .map { _ in .default("Home") }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: updatingTitle)
      .disposed(by: disposeBag)
    
    ModelController.shared.dataUpdatingStatus
      .delay(.seconds(4), scheduler: eventScheduler)
      .filter { [weak self] status in
        guard let self = self,
          self.isRefreshing.value == false else {
            return false
        }
        switch status {
        case .error(_):
          return true
        default:
          return false
        }
      }
      .map { _ in .default("Home") }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: updatingTitle)
      .disposed(by: disposeBag)
  }
  
  private func bindActions() {
    refresh
      .filter { $0 }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .subscribe(onNext: { _ in
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
  
//  func setupImage(for shop: ShopData) -> Completable {
//    let subject = PublishSubject<Void>()
//    NetworkController.shared.setupPreviewImage(in: shop) {
//      if let _ = shop.previewImage {
//        subject.onCompleted()
//      } else {
//        guard let category = shop.category else {
//          subject.onCompleted()
//          return
//        }
//        NetworkController.shared.setupDefaultImage(in: category) {
//          shop.previewImage = category.defaultImage
//          subject.onCompleted()
//        }
//      }
//    }
//    
//    return subject
//      .asObservable()
//      .take(1)
//      .ignoreElements()
//  }
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
