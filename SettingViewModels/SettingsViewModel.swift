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
import SafariServices

class SettingsViewModel {
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private var navigator: Navigator!
  
  // MARK: - Input
  let showFeedbackVC = PublishRelay<(UIViewController, FeedbackViewModel.FeedbackType)>()
  
  let openOurProducts = PublishRelay<(UIViewController)>()
  
  let clearCache = PublishRelay<Void>()
  
  let pushNotifications: BehaviorRelay<Bool>!
  
  let viewDidAppear = PublishRelay<Void>()
  
  // MARK: - Output
  private let _pushNotificationsSwitherShould = PublishRelay<Bool>()
  
  let pushNotificationsSwitherShould: Driver<Bool>
  
  let contactUsEmail: Driver<String?>
  
  // MARK: - Init
  init() {
    self.navigator = Navigator()
    
    self.pushNotificationsSwitherShould = _pushNotificationsSwitherShould.asDriver(onErrorJustReturn: false)
    
    let pushIsOn = UserDefaults.standard.bool(forKey: UserDefaultKeys.pushNotifications.rawValue)
    pushNotifications = BehaviorRelay<Bool>(value: pushIsOn)
    
    contactUsEmail = NetworkController.shared.serverPack
      .map { servers in
        return servers?.contactEmail
      }
      .asDriver(onErrorJustReturn: nil)
    
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
          let systemPermission = NotificationProvider.shared.notificationStatus.value
          if !systemPermission {
            self.requestNotifications()
          }
        }
      })
      .disposed(by: disposeBag)
    
    NotificationProvider.shared.notificationStatus
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
    
    if UserDefaults.standard.object(forKey: UserDefaultKeys.pushNotifications.rawValue) == nil {
      NotificationProvider.shared.userPermissionDidChange
        .take(1)
        .observeOn(defaultScheduler)
        .subscribe(onNext: { pushIsOn in
          self.pushNotifications.accept(pushIsOn)
          self._pushNotificationsSwitherShould.accept(pushIsOn)
        })
        .disposed(by: disposeBag)
    }
    
    viewDidAppear
      .take(1)
      .withLatestFrom(NotificationProvider.shared.notificationStatus)
      .filter { !$0 }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [unowned self] _ in
        if UserDefaults.standard.object(forKey: UserDefaultKeys.pushNotifications.rawValue) == nil {
          self.pushNotifications.accept(true)
          self._pushNotificationsSwitherShould.accept(true)
        }
      })
      .disposed(by: disposeBag)
    
    showFeedbackVC
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] (vc, type) in
        self.showFeedbackVC(vc, feedbackType: type)
      })
      .disposed(by: disposeBag)
    
    openOurProducts
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] vc in
        self.openWebsite(vc)
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
    NotificationProvider.shared.requestAuthorization()
      .take(1)
      .filter { !$0 }
      .subscribe(onNext: { [weak self] _ in
        self?.pushNotifications.accept(false)
        self?._pushNotificationsSwitherShould.accept(false)
      })
      .disposed(by: disposeBag)
  }
}

  // MARK: - Show Feedback View Controller
extension SettingsViewModel {
  
  private func showFeedbackVC(_ vc: UIViewController, feedbackType: FeedbackViewModel.FeedbackType) {
    navigator.showFedbackVC(sender: vc,
                            feedbackType: feedbackType)
  }
}

  // MARK: - openURL
extension SettingsViewModel {
  
  private func openWebsite(_ vc: UIViewController) {
    guard let link = NetworkController.shared.serverPack.value?.businessCardWebsite,
      let url = URL(string: link) else {
      return
    }
    
    let safariVC = SFSafariViewController(url: url)
    vc.present(safariVC, animated: true, completion: nil)
  }
}
