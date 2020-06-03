//
//  HomeAnimatingSubtitleView.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 31.05.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class HomeAnimatingSubtitleView: UIView {
  let promt = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("not implemented")
  }
}

  // MARK: - Layouts
extension HomeAnimatingSubtitleView {
  
  func setupLayouts() {
    promt.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(promt)
    
    self.backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
    
    promt.font = UIFont.preferredFont(forTextStyle: .subheadline)
    promt.adjustsFontForContentSizeCategory = true
    promt.textAlignment = .center
    promt.textColor = .white
    
    let spacing = CGFloat(10)
    NSLayoutConstraint.activate([
      promt.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
      promt.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
      promt.topAnchor.constraint(equalTo: self.topAnchor),
      promt.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
  }
}
