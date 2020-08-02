//
//  NotificationService.swift
//  GetCouponNotificationService
//
//  Created by Nikita Konashenko on 29.07.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
  
  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?
  
  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
    
    URLSession.shared.reset(completionHandler: {})
    
    if let bestAttemptContent = bestAttemptContent {
      // Modify the notification content here...
      
      if let kind = bestAttemptContent.userInfo["kind"] as? String {
        if kind == "favorites-updated" {
          bestAttemptContent.title = NSLocalizedString("new-coupon-in", comment: "New coupon in") + bestAttemptContent.title
        }
        
      } else {
        bestAttemptContent.title = NSLocalizedString(bestAttemptContent.title, comment: "pay attention title")
        bestAttemptContent.body = NSLocalizedString(bestAttemptContent.body, comment: "pay attention body")
      }
      
      bestAttemptContent.sound = .default
      
      contentHandler(bestAttemptContent)
    }
  }
  
  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }
  
}
