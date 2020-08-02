//
//  NotificationProvider.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 28.07.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import UserNotifications

class NotificationProvider {
  
  static let shared = NotificationProvider()
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let updatesScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
  
  /// System Permission to Send Push Notifications
  let notificationStatus = BehaviorRelay<Bool>(value: false)
  
  let userPermissionDidChange = PublishRelay<Bool>()
  
  var deviceToken: String? {
    return UserDefaults.standard.object(forKey: UserDefaultKeys.APNsDeviceToken.rawValue) as? String
  }
  
  var pushConfiguration: PushConfiguration? {
    return PushConfiguration()
  }
  
  init() {
    setupObservers()
  }
  
  private func setupObservers() {
    notificationStatus
      .skip(1)
      .filter { $0 }
      .take(1)
      .subscribeOn(defaultScheduler)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { _ in
        UIApplication.shared.registerForRemoteNotifications()
      })
      .disposed(by: disposeBag)
    
    ///  Request permission to push on first adding favorite shop
    ModelController.shared.favoriteCollections
      .skip(1)
      .filter { !$0.isEmpty }
      .take(1)
      .filter { collection in
        if UserDefaults.standard.object(forKey: UserDefaultKeys.pushNotifications.rawValue) == nil {
          return true
        }
        
        return false
      }
      .map { _ in }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.requestAuthorization()
          .subscribe(onNext: { [weak self] pushIsOn in
            UserDefaults.standard.set(pushIsOn, forKey: UserDefaultKeys.pushNotifications.rawValue)
            
            self?.userPermissionDidChange.accept(pushIsOn)
          })
          .disposed(by: self.disposeBag)
      })
      .disposed(by: disposeBag)
  }
  
  func updateNotificationStatus() {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { [weak self] setting in
      if setting.authorizationStatus == .authorized {
        self?.notificationStatus.accept(true)
        
      } else {
        self?.notificationStatus.accept(false)
      }
    }
  }
  
  func performNotification(with notificationOption: [String : AnyObject]) {
    guard let kind = notificationOption["kind"] as? String else { return }
    
    switch kind {
    case "favorites-updated":
      ModelController.shared.defaultTabBarItem.accept(1)
    default:
      return
    }
  }
  
  // MARK: - Authorization
  func requestAuthorization() -> Observable<Bool> {
    return Observable.create { observer in
      let center = UNUserNotificationCenter.current()
      center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        if granted {
          debugPrint("Permission to send notifications recived")
          observer.onNext(true)
          
        } else {
          debugPrint("Permission to send notifications not recived")
          observer.onNext(false)
        }
      }
      
      return Disposables.create()
    }
  }
  
  
  func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    
    debugPrint("Device Token: \(token)")
    
    UserDefaults.standard.set(token, forKey: UserDefaultKeys.APNsDeviceToken.rawValue)
  }
  
  func application(didFailToRegisterForRemoteNotificationsWithError error: Error) {
    debugPrint("Failed to register: \(error)")
    
    UserDefaults.standard.set(nil, forKey: UserDefaultKeys.APNsDeviceToken.rawValue)
  }
  
}
