//
//  PromocodeView.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 07.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class PromocodeView: UIView {
  
  let promocodeLabel = UILabel()
//  private let copyLabel = UILabel()
//  let button = UIButton()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(promocodeLabel)
//    addSubview(copyLabel)
//    addSubview(button)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func updateConstraints() {
    promocodeLabel.translatesAutoresizingMaskIntoConstraints = false
//    copyLabel.translatesAutoresizingMaskIntoConstraints = false
//    button.translatesAutoresizingMaskIntoConstraints = false
    
    promocodeLabel.font = UIFont.preferredFont(forTextStyle: .body)
    promocodeLabel.adjustsFontForContentSizeCategory = true
    promocodeLabel.textAlignment = .center
    promocodeLabel.textColor = UIColor(named: "BlueTintColor")
    
//    copyLabel.font = UIFont.preferredFont(forTextStyle: .body)
//    copyLabel.adjustsFontForContentSizeCategory = true
//    copyLabel.textAlignment = .center
//    copyLabel.textColor = .white
//    copyLabel.text = "Copied Successfully"
//    copyLabel.alpha = 0
    
//    backgroundColor = .clear
    layer.borderWidth = 1
    layer.borderColor = UIColor(named: "BlueTintColor")?.cgColor
    layer.cornerRadius = 10
    clipsToBounds = true
    
    NSLayoutConstraint.activate([
//      button.leadingAnchor.constraint(equalTo: leadingAnchor),
//      button.trailingAnchor.constraint(equalTo: trailingAnchor),
//      button.topAnchor.constraint(equalTo: topAnchor),
//      button.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      promocodeLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 10),
      promocodeLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -10),
      promocodeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5 ),
      promocodeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
      
//      copyLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 10),
//      copyLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -10),
//      copyLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5 ),
//      copyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
    ])
    
    super.updateConstraints()
  }
  
//  func animateCopying() {
//    let animator = UIViewPropertyAnimator(duration: 2, curve: .easeOut, animations: { [weak self] in
//      guard let self = self else { return }
//      self.backgroundColor = UIColor(named: "BlueTintColor")
//      self.promocodeLabel.alpha = 0
//      self.copyLabel.alpha = 1
//    })
//
//    animator.addCompletion { position in
//      if position == .end {
//        let animator = UIViewPropertyAnimator(duration: 2, curve: .easeIn, animations: { [weak self] in
//          guard let self = self else { return }
//          self.backgroundColor = .clear
//          self.promocodeLabel.alpha = 1
//          self.copyLabel.alpha = 0
//
//        })
//        animator.startAnimation()
//      }
//    }
//
//    animator.startAnimation()
//  }
}
