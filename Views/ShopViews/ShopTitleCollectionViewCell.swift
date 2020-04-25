//
//  ShopTitleCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 08.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ShopTitleCollectionViewCell: UICollectionViewCell {
  
  static let reuseIdentifier = "shop-title-cell-reuse-identifier"
  
  let titleLabel = UILabel()
  let subtitleLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("not implemented")
  }
}

extension ShopTitleCollectionViewCell {
  
  func setupLayouts() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(titleLabel)
    contentView.addSubview(subtitleLabel)
    
    titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    titleLabel.adjustsFontForContentSizeCategory = true
    titleLabel.textAlignment = .center
    
    subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    subtitleLabel.adjustsFontForContentSizeCategory = true
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.numberOfLines = 2
    subtitleLabel.textAlignment = .center
    
    let spacing = CGFloat(10)
    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
      titleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4),
      
      subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
      subtitleLabel.firstBaselineAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing * 2),
      subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
    ])
  }
}
