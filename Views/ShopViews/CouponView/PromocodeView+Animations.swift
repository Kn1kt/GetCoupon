//
//  PromocodeView+Animations.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 05.05.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class AnimatedPromocodeView: PromocodeView {

  let button = UIButton()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(copyLabel)
    addSubview(button)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func updateConstraints() {
    copyLabel.translatesAutoresizingMaskIntoConstraints = false
    button.translatesAutoresizingMaskIntoConstraints = false
    
    copyLabel.font = UIFont.systemFont(ofSize: 22, weight: .regular)
    copyLabel.adjustsFontForContentSizeCategory = true
    copyLabel.textAlignment = .center
    copyLabel.textColor = .white
    copyLabel.text = NSLocalizedString("copied-successfully", comment: "Copied Successfully")
    copyLabel.alpha = 0
    copyLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
    
    backgroundColor = .clear
    
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: leadingAnchor),
      button.trailingAnchor.constraint(equalTo: trailingAnchor),
      button.topAnchor.constraint(equalTo: topAnchor),
      button.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      copyLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 10),
      copyLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -10),
      copyLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5 ),
      copyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
    ])
    
    super.updateConstraints()
    layer.cornerRadius = 8
    promocodeLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
  }
  
  override func layoutSubviews() {
    layer.borderColor = UIColor(named: "BlueTintColor")?.cgColor
  }
  
  // MARK: - Animations
  private let copyLabel = UILabel()
  private var backgroundInAnimator: UIViewPropertyAnimator?
  private var backgroundOutAnimator: UIViewPropertyAnimator?
  
  private var labelInAnimator: UIViewPropertyAnimator?
  private var labelOutAnimator: UIViewPropertyAnimator?
  
  private var isAnimating: Bool {
    return backgroundInAnimator != nil
      || backgroundOutAnimator != nil
      || labelInAnimator != nil
      || labelOutAnimator != nil
  }
  
  func animateCopying() {
    guard !isAnimating else {
      return
    }
    
    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
    impactFeedbackgenerator.prepare()
    
    backgroundInAnimator = UIViewPropertyAnimator(duration: 1,
                                                curve: .easeOut,
                                                animations: { [weak self] in
                                                guard let self = self else { return }
                                                self.backgroundColor = UIColor(named: "BlueTintColor")
    })
    
    backgroundInAnimator?.addCompletion { [weak self] position in
      guard position == .end else { return }
      self?.backgroundInAnimator = nil
      self?.backgroundOutAnimator = UIViewPropertyAnimator(duration: 1,
                                                  curve: .easeIn,
                                                  animations: { [weak self] in
                                                    guard let self = self else { return }
                                                    self.backgroundColor = .clear
      })
      self?.backgroundOutAnimator?.addCompletion { [weak self] position in
        guard position == .end else { return }
        self?.backgroundOutAnimator = nil
      }
      self?.backgroundOutAnimator?.startAnimation(afterDelay: 0.5)
    }
    
    labelInAnimator = UIViewPropertyAnimator(duration: 1,
                                           dampingRatio: 0.7,
                                           animations: { [weak self] in
                                           guard let self = self else { return }
                                           self.promocodeLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
                                           self.promocodeLabel.alpha = 0
                                           self.copyLabel.transform = .identity
                                           self.copyLabel.alpha = 1
    })
    
    labelInAnimator?.addCompletion { [weak self] position in
      guard position == .end else { return }
      self?.labelInAnimator = nil
      self?.labelOutAnimator = UIViewPropertyAnimator(duration: 1,
                                                   dampingRatio: 0.7,
                                                   animations: { [weak self] in
                                                     guard let self = self else { return }
                                                     self.promocodeLabel.transform = .identity
                                                     self.promocodeLabel.alpha = 1
                                                     self.copyLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
                                                     self.copyLabel.alpha = 0
      })
      
      self?.labelOutAnimator?.addCompletion { [weak self] position in
        guard position == .end else { return }
        self?.labelOutAnimator = nil
      }
      self?.labelOutAnimator?.startAnimation(afterDelay: 1)
    }
    
    backgroundInAnimator?.startAnimation()
    labelInAnimator?.startAnimation()
    impactFeedbackgenerator.impactOccurred()
  }
  
  func stopAnimating() {
    guard isAnimating else { return }
    
    if let backgroundIn = backgroundInAnimator {
      backgroundIn.stopAnimation(true)
      backgroundInAnimator = nil
      
    } else if let backgroundOut = backgroundOutAnimator {
      backgroundOut.stopAnimation(true)
      backgroundOutAnimator = nil
    }
    
    if let labelIn = labelInAnimator {
      labelIn.stopAnimation(true)
      labelInAnimator = nil
      
    } else if let labelOut = labelOutAnimator {
      labelOut.stopAnimation(true)
      labelOutAnimator = nil
    }
    
    setAnimatableViewToDefault()
  }
  
  private func setAnimatableViewToDefault() {
    backgroundColor = .clear
    promocodeLabel.transform = .identity
    promocodeLabel.alpha = 1
    copyLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
    copyLabel.alpha = 0
  }
}
