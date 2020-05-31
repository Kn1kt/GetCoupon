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
    
    NSLayoutConstraint.activate([
      promt.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      promt.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      promt.topAnchor.constraint(equalTo: self.topAnchor),
      promt.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
  }
}
