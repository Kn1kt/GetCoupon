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
  
  let disposeBag = DisposeBag()
  
  let titleLabel = UILabel()
  let subtitleLabel = UILabel()
  let expirationDateLabel = UILabel()
  let promocodeView = AnimatedPromocodeView()
  let shareButton = UIButton()
  let exitButton = UIButton()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    
    promocodeView.button.rx.tap
      .throttle(RxTimeInterval.seconds(3), scheduler: MainScheduler.instance)
      .subscribeOn(MainScheduler.instance)
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
    self.backgroundColor = .systemBackground
    self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOpacity = 0.1
    self.layer.shadowRadius = 10
    
    self.addSubview(titleLabel)
    self.addSubview(shareButton)
    self.addSubview(exitButton)
    self.addSubview(subtitleLabel)
    self.addSubview(promocodeView)
    self.addSubview(expirationDateLabel)
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    exitButton.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    expirationDateLabel.translatesAutoresizingMaskIntoConstraints = false
    promocodeView.translatesAutoresizingMaskIntoConstraints = false
    shareButton.translatesAutoresizingMaskIntoConstraints = false
    
    titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    titleLabel.adjustsFontForContentSizeCategory = true
    titleLabel.textAlignment = .left
    
    subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    subtitleLabel.adjustsFontForContentSizeCategory = true
    subtitleLabel.numberOfLines = 0
    subtitleLabel.textAlignment = .left
    
    expirationDateLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    expirationDateLabel.adjustsFontForContentSizeCategory = true
    expirationDateLabel.textColor = .secondaryLabel
    expirationDateLabel.textAlignment = .left
    
    shareButton.setBackgroundImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
    shareButton.setBackgroundImage(UIImage(systemName: "square.and.arrow.up.fill"), for: .highlighted)
//    shareButton.tintColor = UIColor(named: "BlueTintColor")
    shareButton.tintColor = .secondaryLabel
    
    exitButton.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
    exitButton.setBackgroundImage(UIImage(systemName: "xmark"), for: .highlighted)
    exitButton.tintColor = .secondaryLabel
//    exitButton.tintColor = UIColor(named: "BlueTintColor")
    
    let spacing = CGFloat(20)
    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
      titleLabel.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -spacing),
      titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 4.0),
      
      shareButton.trailingAnchor.constraint(lessThanOrEqualTo: exitButton.leadingAnchor, constant: -spacing),
      shareButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
      shareButton.heightAnchor.constraint(equalToConstant: 25),
      shareButton.widthAnchor.constraint(equalTo: shareButton.heightAnchor, multiplier: 0.9),
      
      exitButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
      exitButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
      exitButton.heightAnchor.constraint(equalTo: shareButton.heightAnchor, multiplier: 1.0),
      exitButton.widthAnchor.constraint(equalTo: exitButton.heightAnchor, multiplier: 0.9),
      
      subtitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
      subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
      subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 2.0),
      
      promocodeView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
      promocodeView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
      promocodeView.topAnchor.constraint(equalToSystemSpacingBelow: subtitleLabel.bottomAnchor, multiplier: 2.0),
      promocodeView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
      
      expirationDateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
      expirationDateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
      expirationDateLabel.topAnchor.constraint(equalToSystemSpacingBelow: promocodeView.bottomAnchor, multiplier: 1.5),
      self.bottomAnchor.constraint(equalToSystemSpacingBelow: expirationDateLabel.bottomAnchor, multiplier: 4.0)
    ])
    
  }
}

extension CouponPopupView: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if touch.view == exitButton || touch.view == shareButton {
      return false
    }
    
    return true
  }
}
