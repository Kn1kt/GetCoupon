//
//  ShopCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 07.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class ShopPlainCollectionViewCell: UICollectionViewCell {
  
  var disposeBag = DisposeBag()
  
  static let reuseIdentifier = "shop-plain-cell-reuse-identifier"
  
  let imageView = UIImageView()
  let subtitleLabel = UILabel()
  let promocodeView = PromocodeView()
  let addingDateLabel = UILabel()
  let estimatedDateLabel = UILabel()
//  let backView = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("not implemented")
  }
}

extension ShopPlainCollectionViewCell {
  
  func setupLayouts() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    promocodeView.translatesAutoresizingMaskIntoConstraints = false
    addingDateLabel.translatesAutoresizingMaskIntoConstraints = false
    estimatedDateLabel.translatesAutoresizingMaskIntoConstraints = false
//    backView.translatesAutoresizingMaskIntoConstraints = false
    
//    contentView.addSubview(backView)
    
    contentView.clipsToBounds = true
    contentView.layer.cornerRadius = 10
    
    contentView.addSubview(imageView)
    contentView.addSubview(subtitleLabel)
    contentView.addSubview(promocodeView)
    contentView.addSubview(addingDateLabel)
    contentView.addSubview(estimatedDateLabel)
    contentView.backgroundColor = .secondarySystemGroupedBackground
    
    subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    subtitleLabel.adjustsFontForContentSizeCategory = true
    //subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.numberOfLines = 3
    
    addingDateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
    addingDateLabel.adjustsFontForContentSizeCategory = true
    addingDateLabel.textColor = .tertiaryLabel
    
    estimatedDateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
    estimatedDateLabel.adjustsFontForContentSizeCategory = true
    estimatedDateLabel.textColor = .tertiaryLabel
    
    promocodeView.layer.cornerRadius = 7
    
    
//    contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
//    contentView.layer.shadowOffset = CGSize(width: 0, height: 10)
//    contentView.layer.shadowOpacity = 1
//    contentView.layer.shadowRadius = 15
//    contentView.layer.shouldRasterize = true
//    contentView.layer.rasterizationScale = UIScreen.main.scale
    
    imageView.backgroundColor = .systemGray3
//    imageView.layer.cornerRadius = 6
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    
    let spacing = CGFloat(10)
    
    NSLayoutConstraint.activate([
//      backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//      backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//      backView.topAnchor.constraint(equalTo: contentView.topAnchor),
//      backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
      imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.1),
      
      subtitleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing * 1.5),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
      subtitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
      subtitleLabel.bottomAnchor.constraint(equalTo: promocodeView.topAnchor, constant: -spacing),
      
      promocodeView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing * 1.5),
      promocodeView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -spacing),
      promocodeView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -spacing / 2),
      promocodeView.heightAnchor.constraint(equalToConstant: 32),
      
      addingDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
      addingDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.centerXAnchor, constant: -spacing),
      addingDateLabel.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor),
      addingDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing),
      
      estimatedDateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.centerXAnchor, constant: spacing),
      estimatedDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
      estimatedDateLabel.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor),
      estimatedDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing),
    ])
  }
}

//MARK: - CellWithImageProtocol
extension ShopPlainCollectionViewCell: CellWithImage {
  
  override func prepareForReuse() {
    disposeBag = DisposeBag()
    imageView.image = nil
    imageView.backgroundColor = .systemGray3
  }
}
