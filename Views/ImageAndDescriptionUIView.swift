//
//  ImageAndDescriptionUIView.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 08.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ImageAndDescriptionUIView: UIView {
  
  let imageView = UIImageView()
  let button = UIButton()
  let imageDescription = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("not implemented")
  }
}

extension ImageAndDescriptionUIView {
  
  func setupLayouts() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageDescription.translatesAutoresizingMaskIntoConstraints = false
    button.translatesAutoresizingMaskIntoConstraints = false
    
    button.addSubview(imageDescription)
    button.addSubview(imageView)
    addSubview(button)
    
    imageView.backgroundColor = .clear
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .secondaryLabel
    
    imageDescription.font = UIFont.preferredFont(forTextStyle: .body)
    imageDescription.adjustsFontForContentSizeCategory = true
    imageDescription.textColor = .tertiaryLabel
    imageDescription.textAlignment = .center
    
    let spacing = CGFloat(10)
    
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: leadingAnchor),
      button.trailingAnchor.constraint(equalTo: trailingAnchor),
      button.topAnchor.constraint(equalTo: topAnchor),
      button.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      imageView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
      imageView.topAnchor.constraint(equalTo: button.topAnchor),
      imageView.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.22),
      
      imageDescription.leadingAnchor.constraint(equalTo: button.leadingAnchor),
      imageDescription.trailingAnchor.constraint(equalTo: button.trailingAnchor),
      imageDescription.firstBaselineAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing),
      imageDescription.bottomAnchor.constraint(equalTo: button.bottomAnchor)
    ])
  }
}
