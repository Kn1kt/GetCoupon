//
//  FooterSupplementaryView.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 19.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class ShowMoreSupplementaryView: UICollectionReusableView {
  
  let showMoreButton = ShowMoreUIButton()
  var disposeBag = DisposeBag()
  
  static let reuseIdentifier = "show-more-supplementory-reuse-identifier"
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("not Implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
  
}

extension ShowMoreSupplementaryView {
  
  func setupLayouts() {
    addSubview(showMoreButton)
    showMoreButton.translatesAutoresizingMaskIntoConstraints = false
    
    layer.cornerRadius = 6
    layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
    layer.shadowOffset = CGSize(width: 0, height: 4)
    layer.shadowOpacity = 1
    layer.shadowRadius = 15
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    backgroundColor = .secondarySystemGroupedBackground
    
    NSLayoutConstraint.activate([
      showMoreButton.leadingAnchor.constraint(equalTo: leadingAnchor),
      showMoreButton.trailingAnchor.constraint(equalTo: trailingAnchor),
      showMoreButton.topAnchor.constraint(equalTo: topAnchor),
      showMoreButton.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
}
