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
  let pushNotificationsDisabled = PublishRelay<Bool>()
  
  // MARK: - Init
  init() {
    self.navigator = Navigator()
    
    let forceUpdating = UserDefaults.standard.bool(forKey: UserDefaultKeys.forceCatalogUpdating.rawValue)
    forceCatalogUpdating = BehaviorRelay<Bool>(value: forceUpdating)
    
    let pushIsOn = UserDefaults.standard.bool(forKey: UserDefaultKeys.pushNotifications.rawValue)
    pushNotifications = BehaviorRelay<Bool>(value: pushIsOn)
    
    bindOutput()
    bindActions()
  }
  
  private func bindOutput() {
    forceCatalogUpdating
      .skip(1)
      .debounce(RxTimeInterval.milliseconds(500), scheduler: defaultScheduler)
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .subscribe(onNext: { forceUpdating in
        debugPrint("Set force updating to: \(forceUpdating)")
        UserDefaults.standard.set(forceUpdating, forKey: UserDefaultKeys.forceCatalogUpdating.rawValue)
      })
      .disposed(by: disposeBag)
    
    let notificationStatus = Observable.merge([pushNotifications.asObservable(), pushNotificationsDisabled.asObservable()])
    
//    pushNotifications
    notificationStatus
      .skip(1)
      .debounce(RxTimeInterval.milliseconds(500), scheduler: defaultScheduler)
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .subscribe(onNext: { pushIsOn in
        debugPrint("Set push notifications to: \(pushIsOn)")
        UserDefaults.standard.set(pushIsOn, forKey: UserDefaultKeys.pushNotifications.rawValue)
        
        if pushIsOn {
          let center = UNUserNotificationCenter.current()
          center.getNotificationSettings { [weak self] setting in
            guard setting.authorizationStatus == .authorized else {
              self?.requestNotifications()
              return
            }
            
          }
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func bindActions() {
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
    
    UserDefaults.standard.rx
      .observe(Bool.self, UserDefaultKeys.pushNotifications.rawValue)
      .subscribe(onNext: { [weak self] isOn in
        guard let self = self,
              let isOn = isOn else { return }
        
        if !isOn, self.pushNotifications.value {
          self.pushNotificationsDisabled.accept(false)
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func requestNotifications() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
      if granted {
        debugPrint("Permission to send notifications recived")
      } else {
        debugPrint("Permission to send notifications not recived")
//        self?.pushNotificationsDisabled.accept(false)
        UserDefaults.standard.set(false, forKey: UserDefaultKeys.pushNotifications.rawValue)
      }
      
//      UserDefaults.standard.set(granted, forKey: UserDefaultKeys.pushNotifications.rawValue)
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
