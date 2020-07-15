//
//  EmptyFavoritesView.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 15.07.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class EmptyFavoritesView: UIView {
  
  let titleLabel = UILabel()
  let subtitleLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

 // MARK: - Layouts
extension EmptyFavoritesView {
  
  func setupLayouts() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(titleLabel)
    addSubview(subtitleLabel)
    
    isUserInteractionEnabled = false
    
    titleLabel.adjustsFontForContentSizeCategory = true
    titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
    titleLabel.textColor = .label
    titleLabel.text = NSLocalizedString("is-empty-there-title", comment: "Is Empty There")
    
    subtitleLabel.adjustsFontForContentSizeCategory = true
    subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    subtitleLabel.numberOfLines = 0
    subtitleLabel.textAlignment = .center
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.text = NSLocalizedString("is-empty-there-subtitle", comment: "Is Empty There")
    
    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
      titleLabel.topAnchor.constraint(equalTo: topAnchor),
      
      subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
      subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),
      subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
}
