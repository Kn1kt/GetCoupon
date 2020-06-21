//
//  addToFavoritesButton.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 26.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class AddToFavoritesButton: UIButton {
  
  weak var cell: ShopData?
  let checkbox = LikeImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

  // MARK: - Layouts
extension AddToFavoritesButton {
  
  func setupLayouts() {
    checkbox.image = UIImage(systemName: "heart")
    checkbox.highlightedImage = UIImage(systemName: "heart.fill")
    checkbox.tintColor = .systemGray4
    checkbox.isUserInteractionEnabled = false
    checkbox.contentMode = .scaleAspectFit
    
    checkbox.translatesAutoresizingMaskIntoConstraints = false
    addSubview(checkbox)
    
    NSLayoutConstraint.activate([
      checkbox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutMargins.left),
      checkbox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -layoutMargins.right),
      checkbox.topAnchor.constraint(equalTo: topAnchor, constant: layoutMargins.top),
      checkbox.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -layoutMargins.bottom)
    ])
  }
}
