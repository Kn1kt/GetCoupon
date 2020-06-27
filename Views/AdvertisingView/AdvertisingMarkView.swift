//
//  AdvertisingMarkView.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 26.06.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class AdvertisingMarkView: UIView {
  let textLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

  // MARK: - Layouts
extension AdvertisingMarkView {
  
  func setupLayouts() {
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(textLabel)
    
    layer.cornerRadius = 3
    clipsToBounds = true
    backgroundColor = .systemYellow
    
    textLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
//    textLabel.adjustsFontForContentSizeCategory = true
    textLabel.textColor = .black
    textLabel.text = "Ad"
    
    let spacing = CGFloat(5)
    
    NSLayoutConstraint.activate([
      textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
      textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
      textLabel.topAnchor.constraint(equalTo: topAnchor),
      textLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
}
