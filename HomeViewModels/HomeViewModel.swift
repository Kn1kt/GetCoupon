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
import SafariServices

class HomeViewModel {
  
  enum TitleTypes {
    case `default`(String)
    case dowloading(String)
    case downloaded(String)
    case waitingForNetwork(String)
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
  
  let selectedCell = PublishRelay<(UIViewController, ShopData)>()
  
  // MARK: - Output
  private let _collections = BehaviorRelay<[ShopCategoryData]>(value: [])
  
  let collections: Observable<[ShopCategoryData]>
  
  /// Current status of refresh controller
  let isRefreshing = BehaviorRelay<Bool>(value: true)
  
  /// Send stopRefreshing to refresh
  let updateRefreshingStatus: Driver<Bool>
  
  let updatingTitle = BehaviorRelay<TitleTypes>(value: .default(NSLocalizedString("default-status", comment: "Home")))
  
  let advEnabled = BehaviorRelay<Bool>(value: false)
  
  let advSections = BehaviorRelay<Set<Int>>(value: Set<Int>())
  
  let showOnboarding = Observable<Bool>.deferred {
    let onboardingDidShow = UserDefaults.standard.bool(forKey: UserDefaultKeys.onboardingScreenDidShow.rawValue)
    
    if onboardingDidShow {
      return Observable.just(false)
      
    } else {
      UserDefaults.standard.set(true, forKey: UserDefaultKeys.onboardingScreenDidShow.rawValue)
      return Observable.just(true)
    }
  }
  
  let scrollToTopGesture = ModelController.shared.scrollToTopGesture.asObservable()
  
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
//      .delay(.seconds(1), scheduler: eventScheduler)
      .debounce(.seconds(1), scheduler: eventScheduler)
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: _collections)
      .disposed(by: disposeBag)
    
    model.advSections
      .observeOn(defaultScheduler)
      .bind(to: advSections)
      .disposed(by: disposeBag)
    
    model.advEnabled
      .observeOn(defaultScheduler)
      .bind(to: advEnabled)
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
          return .default(NSLocalizedString("default-status", comment: "Home"))
        case .updating:
          return .dowloading(NSLocalizedString("updating-status", comment: "Updating..."))
        case .updated:
          return .downloaded(NSLocalizedString("updated-status", comment: "Successfully Updated"))
        case .waitingForNetwork:
          return .waitingForNetwork(NSLocalizedString("waiting-for-nework-status", comment: "Waiting for Network..."))
        case .error(let e):
          return .error(String(e.localizedDescription.prefix(while: { $0 != "." })), NSLocalizedString("error-status", comment: "Udpate Error"))
        }
      }
      .filter { status in
        switch status {
        case .downloaded(_), .waitingForNetwork(_):
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
      .map { _ in .default(NSLocalizedString("default-status", comment: "Home")) }
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
        case .waitingForNetwork:
          return true
        default:
          return false
        }
      }
      .map { _ in .default(NSLocalizedString("waiting-for-nework-status", comment: "Waiting for Network...")) }
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
    
    selectedCell
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] (vc, cell) in
        if cell.name == "AdvertisingCell" {
          self.openWebsite(vc, cell: cell)
        } else {
          let isEnabled = !self.isRefreshing.value
          self.showShopVC(vc, shop: cell, favoritesButton: isEnabled)
        }
      })
      .disposed(by: disposeBag)
  }
}

  // MARK: - Setup Image
extension HomeViewModel {
  
  func setupPreviewImage(for shop: ShopData) -> Completable {
    return ModelController.shared.setupPreviewImage(for: shop)
  }
  
  func setupAdvImage(for cell: ShopData) -> Completable {
    return ModelController.shared.setupAdvImage(for: cell)
  }
}

  // MARK: - Show Home Detail View Controller
extension HomeViewModel {
  
  private func showDetailVC(_ sender: ShowMoreUIButton, vc: UIViewController) {
    guard let sectionTitle = sender.sectionTitle,
          let section = model.section(for: sectionTitle) else { return }
    
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

  // MARK: - openURL
extension HomeViewModel {
  
  func openWebsite(_ vc: UIViewController, cell: ShopData) {
    guard let url = URL(string: cell.websiteLink) else {
      return
    }
    
    let safariVC = SFSafariViewController(url: url)
    vc.present(safariVC, animated: true, completion: nil)
  }
}
