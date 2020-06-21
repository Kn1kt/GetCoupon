//
//  LogoWithFavoritesButton.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 08.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class LogoWithFavoritesButton: UIView {
  
  let imageView = UIImageView()
  let favoritesButton = AddToFavoritesButton()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("not implemented")
  }
  
  override func layoutSubviews() {
    updateLayouts()
  }
  
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    if let view = super.hitTest(point, with: event),
      view == favoritesButton {
      return view
    }
    
    return nil
  }
}

extension LogoWithFavoritesButton {
  
  private func setupLayouts() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    favoritesButton.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(imageView)
    addSubview(favoritesButton)
    
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    
    favoritesButton.backgroundColor = .secondarySystemGroupedBackground
    favoritesButton.clipsToBounds = true
    
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
      imageView.topAnchor.constraint(equalTo: topAnchor),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      favoritesButton.trailingAnchor.constraint(equalTo: trailingAnchor),
      favoritesButton.bottomAnchor.constraint(equalTo: bottomAnchor),
      favoritesButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
      favoritesButton.widthAnchor.constraint(equalTo: favoritesButton.heightAnchor)
    ])
  }
  
  private func updateLayouts() {
    layer.cornerRadius = bounds.size.height * 0.5
    imageView.layer.cornerRadius = imageView.bounds.size.height * 0.5
    favoritesButton.layer.cornerRadius = favoritesButton.bounds.height * 0.5
  }
}

  //MARK: - CellWithImageProtocol
extension LogoWithFavoritesButton: CellWithImage {}
