//
//  CouponPopupView.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 03.04.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CouponPopupView: UIView {
  
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  let disposeBag = DisposeBag()
  
  let titleLabel = UILabel()
  let textView =  UITextView()
  var textSnapshot: UIView?
  let snapshotPlace = UIView()
  let expirationDateLabel = UILabel()
  let promocodeView = AnimatedPromocodeView()
  let shareButton = UIButton()
  let exitButton = UIButton()
  
  private var titleHeight: NSLayoutConstraint!
  private var dateHeight: NSLayoutConstraint!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    
    promocodeView.button.rx.tap
      .throttle(RxTimeInterval.seconds(1), latest: false, scheduler: eventScheduler)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.promocodeView.animateCopying()
        UIPasteboard.general.string = self.promocodeView.promocodeLabel.text
      })
      .disposed(by: disposeBag)
  }
  
  required init?(coder: NSCoder) {
    fatalError("not implemented")
  }
}

extension CouponPopupView {
  
  func setupLayouts() {
    self.backgroundColor = .secondarySystemGroupedBackground
    self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOpacity = 0.1
    self.layer.shadowRadius = 10
    
    self.addSubview(titleLabel)
    self.addSubview(shareButton)
    self.addSubview(exitButton)
    self.addSubview(textView)
    self.addSubview(promocodeView)
    self.addSubview(expirationDateLabel)
    self.addSubview(snapshotPlace)
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    exitButton.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    expirationDateLabel.translatesAutoresizingMaskIntoConstraints = false
    promocodeView.translatesAutoresizingMaskIntoConstraints = false
    shareButton.translatesAutoresizingMaskIntoConstraints = false
    snapshotPlace.translatesAutoresizingMaskIntoConstraints = false
    
    snapshotPlace.isUserInteractionEnabled = false
    
    titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
    titleLabel.adjustsFontForContentSizeCategory = true
    titleLabel.numberOfLines = 2
    titleLabel.textAlignment = .left
    
    textView.font = UIFont.preferredFont(forTextStyle: .body)
    textView.tintColor = UIColor(named: "BlueTintColor")
    textView.textColor = .label
    textView.backgroundColor = .secondarySystemGroupedBackground
    textView.adjustsFontForContentSizeCategory = true
    textView.isUserInteractionEnabled = true
    textView.textAlignment = .left
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.bounces = false
    textView.scrollsToTop = false
    textView.showsVerticalScrollIndicator = false
    textView.showsHorizontalScrollIndicator = false
    textView.dataDetectorTypes = [.link]
    textView.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
    
    expirationDateLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    expirationDateLabel.adjustsFontForContentSizeCategory = true
    expirationDateLabel.textColor = .secondaryLabel
    expirationDateLabel.textAlignment = .left
    
    shareButton.setBackgroundImage(UIImage(named: "Share-coupon"), for: .normal)
    shareButton.setBackgroundImage(UIImage(named: "Share-coupon-highlighted"), for: .highlighted)
    shareButton.tintColor = .secondaryLabel
    
    exitButton.setBackgroundImage(UIImage(named: "Xmark"), for: .normal)
    exitButton.setBackgroundImage(UIImage(named: "Xmark"), for: .highlighted)
    exitButton.tintColor = .secondaryLabel
    
    titleHeight = titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: titleLabel.intrinsicContentSize.height)
    titleHeight.isActive = true
    
    dateHeight = expirationDateLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: expirationDateLabel.intrinsicContentSize.height)
    dateHeight.isActive = true
    
    let spacing = CGFloat(20)
    
    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
      titleLabel.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -spacing / 2),
      titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 4.0),
      
      shareButton.trailingAnchor.constraint(lessThanOrEqualTo: exitButton.leadingAnchor, constant: -spacing),
      shareButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
      shareButton.heightAnchor.constraint(equalToConstant: 23),
      shareButton.widthAnchor.constraint(equalTo: shareButton.heightAnchor),
      
      exitButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
      exitButton.centerYAnchor.constraint(equalTo: shareButton.centerYAnchor),
      exitButton.heightAnchor.constraint(equalToConstant: 20),
      exitButton.widthAnchor.constraint(equalTo: exitButton.heightAnchor),
      
      textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
      textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
      textView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 2.0),
      
      snapshotPlace.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
      snapshotPlace.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
      snapshotPlace.topAnchor.constraint(equalTo: textView.topAnchor),
      snapshotPlace.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
      
      promocodeView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
      promocodeView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
      promocodeView.topAnchor.constraint(equalToSystemSpacingBelow: textView.bottomAnchor, multiplier: 2.0),
      promocodeView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
      
      expirationDateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
      expirationDateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
      expirationDateLabel.topAnchor.constraint(equalToSystemSpacingBelow: promocodeView.bottomAnchor, multiplier: 1.5),
      self.bottomAnchor.constraint(equalToSystemSpacingBelow: expirationDateLabel.bottomAnchor, multiplier: 4.0)
    ])
  }
  
  override func layoutSubviews() {
    titleHeight.constant = titleLabel.intrinsicContentSize.height
    dateHeight.constant = expirationDateLabel.intrinsicContentSize.height
  }
}
