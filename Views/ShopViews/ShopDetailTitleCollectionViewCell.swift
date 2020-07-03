//
//  ShopDetailTitleCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 08.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class ShopDetailTitleCollectionViewCell: UICollectionViewCell {
  var disposeBag = DisposeBag()
  
  static let reuseIdentifier = "shop-detail-title-cell-reuse-identifier"
  
  let stackView = UIStackView()
  let couponsCount = ImageAndDescriptionUIView()
  let website = ImageAndDescriptionUIView()
  let share = ImageAndDescriptionUIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("not implemented")
  }
}

extension ShopDetailTitleCollectionViewCell {
  
  func setupLayouts() {
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(stackView)
    
    couponsCount.imageView.image = UIImage(named: "Percent")
    couponsCount.imageView.highlightedImage = UIImage(named: "Percent-highlighted")
    couponsCount.imageDescription.text = NSLocalizedString("coupons", comment: "Coupons")
    
    website.imageView.image = UIImage(named: "Globe")
    website.imageView.highlightedImage = UIImage(named: "Globe-highlighted")
    website.imageDescription.text = NSLocalizedString("website", comment: "Website")
    
    share.imageView.image = UIImage(named: "Share-shop")
    share.imageView.highlightedImage = UIImage(named: "Share-shop-highlighted")
    share.imageDescription.text = NSLocalizedString("share", comment: "Share")
    
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.spacing = 10
    stackView.addArrangedSubview(couponsCount)
    stackView.addArrangedSubview(website)
    stackView.addArrangedSubview(share)
    
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
  }
}

extension ShopDetailTitleCollectionViewCell {
  
  override func prepareForReuse() {
    disposeBag = DisposeBag()
  }
}
