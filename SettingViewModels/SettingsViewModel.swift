//
//  SettingsViewModel.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 26.04.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsViewModel {
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private var navigator: Navigator!
  
  // MARK: - Input
  let showFeedbackVC = PublishRelay<(UIViewController, FeedbackViewModel.FeedbackType)>()
  
  let clearCache = PublishRelay<Void>()
  
  let forceCatalogUpdating: BehaviorRelay<Bool>!
  
  let pushNotifications: BehaviorRelay<Bool>!
  
  // MARK: - Output
  private let _pushNotificationsSwitherShould = PublishRelay<Bool>()
  
  let pushNotificationsSwitherShould: Driver<Bool>
  
  // MARK: - Init
  init() {
    self.navigator = Navigator()
    
    self.pushNotificationsSwitherShould = _pushNotificationsSwitherShould.asDriver(onErrorJustReturn: false)
    
    let forceUpdating = UserDefaults.standard.bool(forKey: UserDefaultKeys.forceCatalogUpdating.rawValue)
    forceCatalogUpdating = BehaviorRelay<Bool>(value: forceUpdating)
    
    let pushIsOn = UserDefaults.standard.bool(forKey: UserDefaultKeys.pushNotifications.rawValue)
    pushNotifications = BehaviorRelay<Bool>(value: pushIsOn)
    
    bindOutput()
    bindActions()
  }
  
  private func bindOutput() {
    
  }
  
  private func bindActions() {
    pushNotifications
      .skip(1)
      .debounce(RxTimeInterval.milliseconds(500), scheduler: defaultScheduler)
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [unowned self] pushIsOn in
        debugPrint("Set push notifications to: \(pushIsOn)")
        UserDefaults.standard.set(pushIsOn, forKey: UserDefaultKeys.pushNotifications.rawValue)
        
        if pushIsOn {
          let systemPermission = ModelController.shared.systemPermissionToPush.value
          if !systemPermission {
            self.requestNotifications()
          }
        }
      })
      .disposed(by: disposeBag)
    
    ModelController.shared.systemPermissionToPush
      .skip(1)
      .withLatestFrom(pushNotifications, resultSelector: { system, user in
        return !system && user
      })
      .filter { $0 }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [unowned self] _ in
        self.pushNotifications.accept(false)
        self._pushNotificationsSwitherShould.accept(false)
      })
      .disposed(by: disposeBag)
    
    forceCatalogUpdating
      .skip(1)
      .debounce(RxTimeInterval.milliseconds(500), scheduler: defaultScheduler)
      .distinctUntilChanged()
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .subscribe(onNext: { forceUpdating in
        debugPrint("Set force updating to: \(forceUpdating)")
        UserDefaults.standard.set(forceUpdating, forKey: UserDefaultKeys.forceCatalogUpdating.rawValue)
      })
      .disposed(by: disposeBag)
    
    showFeedbackVC
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] (vc, type) in
        self.showFeedbackVC(vc, feedbackType: type)
      })
      .disposed(by: disposeBag)
    
    clearCache
      .observeOn(defaultScheduler)
      .subscribe(onNext: {
        ModelController.shared.clearImageCache()
      })
      .disposed(by: disposeBag)
  }
  
  private func requestNotifications() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound]) { [unowned self] (granted, error) in
      if granted {
        debugPrint("Permission to send notifications recived")
      } else {
        debugPrint("Permission to send notifications not recived")
        self.pushNotifications.accept(false)
        self._pushNotificationsSwitherShould.accept(false)
      }
    }
  }
}

  // MARK: - Show Feedback View Controller
extension SettingsViewModel {
  
  private func showFeedbackVC(_ vc: UIViewController, feedbackType: FeedbackViewModel.FeedbackType) {
    navigator.showFedbackVC(sender: vc,
                            feedbackType: feedbackType)
  }
}
