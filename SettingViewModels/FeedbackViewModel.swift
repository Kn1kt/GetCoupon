//
//  FeedbackViewModel.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 25.04.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class FeedbackViewModel {
  
  enum FeedbackType {
    case general
    case coupon
  }
  
  var feedbackType: FeedbackType
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  // MARK: - Input
  let feedbackText = PublishRelay<String>()
  
  // MARK: - Output
  var navBarTitleText = ""
  var titleText = ""
  var subtitleText = ""
  
  // MARK: - Init
  init(feedbackType: FeedbackType) {
    self.feedbackType = feedbackType
    
    bindOutput()
    bindActions()
  }
  
  private func bindOutput() {
    updateLabels()
  }
  
  private func bindActions() {
    feedbackText
      .observeOn(defaultScheduler)
      .subscribe(onNext: { [weak self] feedback in
        guard let self = self else { return }
        // Send feedback to serever
        debugPrint("Recieved: ", feedback)
        
        switch self.feedbackType {
        case .general:
          NetworkController.shared.sendGeneralFeedback(feedback)
        case .coupon:
          NetworkController.shared.sendCoupon(feedback)
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func updateLabels() {
    switch feedbackType {
    case .general:
      navBarTitleText = NSLocalizedString("general-feedback-bar", comment: "Feedback")
      titleText = NSLocalizedString("general-feedback-title", comment: "General Feedback")
      subtitleText = NSLocalizedString("general-feedback-subtitle", comment: "Briefly explain what you love, or what could improve.")
    case .coupon:
      navBarTitleText = NSLocalizedString("share-promocode-screen-bar", comment: "Share")
      titleText = NSLocalizedString("share-promocode-screen-title", comment: "Share Your Coupon")
      subtitleText = NSLocalizedString("share-promocode-screen-subtitle", comment: "Send us a link to the site where you found the coupon.")
    }
  }
}
