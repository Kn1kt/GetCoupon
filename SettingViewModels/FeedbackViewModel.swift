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
      .subscribe(onNext: { feedback in
        // Send feedback to serever
        debugPrint("Recieved: ", feedback)
      })
      .disposed(by: disposeBag)
  }
  
  private func updateLabels() {
    switch feedbackType {
    case .general:
      navBarTitleText = "Feedback"
      titleText = "General Feedback"
      subtitleText = "Briefly explain what you love, or what could improve."
    case .coupon:
      navBarTitleText = "Share"
      titleText = "Share Your Coupon"
      subtitleText = "Send us a link to the site where you found the coupon."
    }
  }
}
