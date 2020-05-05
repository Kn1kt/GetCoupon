//
//  PromocodeView+Animations.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 05.05.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class AnimatedPromocodeView: PromocodeView {
  
  private let copyLabel = UILabel()
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
    
    copyLabel.font = UIFont.preferredFont(forTextStyle: .title3)
    copyLabel.adjustsFontForContentSizeCategory = true
    copyLabel.textAlignment = .center
    copyLabel.textColor = .white
    copyLabel.text = "Copied Successfully"
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
  }
  
  func animateCopying() {
    UIView.animate(withDuration: 1,
                   delay: 0,
                   options: [.curveEaseOut],
                   animations: { [weak self] in
                    guard let self = self else { return }
                    self.backgroundColor = UIColor(named: "BlueTintColor")
    },
                   completion: { _ in
                    UIView.animate(withDuration: 1,
                                   delay: 0.5,
                                   options: [.curveEaseIn],
                                   animations: { [weak self] in
                                    guard let self = self else { return }
                                    self.backgroundColor = .clear
                                    
                    },
                                   completion: nil)
    })
    
    UIView.animate(withDuration: 1,
                   delay: 0,
                   usingSpringWithDamping: 0.7,
                   initialSpringVelocity: 5,
                   options: [],
                   animations: { [weak self] in
                    guard let self = self else { return }
                    self.promocodeLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
                    self.promocodeLabel.alpha = 0
                    self.copyLabel.transform = .identity
                    self.copyLabel.alpha = 1
    },
                   completion: { _ in
                    UIView.animate(withDuration: 1,
                                   delay: 1,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 5,
                                   options: [],
                                   animations: { [weak self] in
                                    guard let self = self else { return }
                                    self.promocodeLabel.transform = .identity
                                    self.promocodeLabel.alpha = 1
                                    self.copyLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
                                    self.copyLabel.alpha = 0
                    }, completion: nil)
    })
  }
}
