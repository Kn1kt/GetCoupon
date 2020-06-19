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
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(promocodeLabel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func updateConstraints() {
    promocodeLabel.translatesAutoresizingMaskIntoConstraints = false
    
    promocodeLabel.font = UIFont.preferredFont(forTextStyle: .body)
    promocodeLabel.adjustsFontForContentSizeCategory = true
    promocodeLabel.textAlignment = .center
    promocodeLabel.textColor = UIColor(named: "BlueTintColor")
    
    layer.borderWidth = 1
    layer.borderColor = UIColor(named: "BlueTintColor")?.cgColor
    layer.cornerRadius = 6
    clipsToBounds = true
    
    NSLayoutConstraint.activate([
      promocodeLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 10),
      promocodeLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -10),
      promocodeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5 ),
      promocodeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
    ])
    
    super.updateConstraints()
  }
  
  override func layoutSubviews() {
    layer.borderColor = UIColor(named: "BlueTintColor")?.cgColor
  }
}
