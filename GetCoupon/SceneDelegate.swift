//
//  SceneDelegate.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 19.10.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    guard let _ = (scene as? UIWindowScene) else { return }
    
    UNUserNotificationCenter.current().delegate = self
    
    if let shortcutItem = connectionOptions.shortcutItem {
      performShortcut(shortcutItem)
    }
  }
  
  func windowScene(_ windowScene: UIWindowScene,
                   performActionFor shortcutItem: UIApplicationShortcutItem,
                   completionHandler: @escaping (Bool) -> Void) {
    performShortcut(shortcutItem)
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    NotificationProvider.shared.updateNotificationStatus()
    checkLastUpdate()
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an inc oming phone call).
    
    ModelController.shared.sceneWillResignActive.accept(())
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    
    updatePushConfiguration()
  }
  
  private func updatePushConfiguration() {
    let encoder = JSONEncoder()
    
    if let pushConfig = NotificationProvider.shared.pushConfiguration,
      let newConfigData = try? encoder.encode(pushConfig) {
      
      if let oldConfigData = UserDefaults.standard.data(forKey: UserDefaultKeys.pushConfigurationVersion.rawValue),
        newConfigData == oldConfigData {
        return
        
      } else {
        UserDefaults.standard.set(newConfigData, forKey: UserDefaultKeys.pushConfigurationVersion.rawValue)
        NetworkController.shared.sendConfiguration(newConfigData)
      }
    }
  }
  
  private func performShortcut(_ shortcutItem: UIApplicationShortcutItem) {
    if shortcutItem.type == "SearchAction" {
      ModelController.shared.defaultTabBarItem.accept(2)

    } else if shortcutItem.type == "OpenFavoritesAction" {
      ModelController.shared.defaultTabBarItem.accept(1)
    }
  }
  
  private func checkLastUpdate() {
    guard let lastDate = UserDefaults.standard.object(forKey: UserDefaultKeys.lastUpdateDate.rawValue) as? Date else { return }
    
    let timePassed = lastDate.timeIntervalSinceNow
    let minutesPassed = Int(abs(timePassed) / 60)
    
    if minutesPassed > 15 {
      ModelController.shared.setupCollections()
    }
  }
}

  // MARK: User Notification Center Delegate
extension SceneDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    if let userInfo = response.notification.request.content.userInfo as? [String: AnyObject] {
      NotificationProvider.shared.performNotification(with: userInfo)
    }
    
    completionHandler()
  }
}
