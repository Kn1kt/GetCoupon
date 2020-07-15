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
    
    clipsToBounds = true
    layer.cornerRadius = 10
    backgroundColor = .secondarySystemGroupedBackground
    selectedBackgroundView = UIView()
    selectedBackgroundView?.backgroundColor = UIColor.systemGray.withAlphaComponent(0.4)
    
    contentView.addSubview(imageView)
    contentView.addSubview(subtitleLabel)
    contentView.addSubview(promocodeView)
    contentView.addSubview(addingDateLabel)
    contentView.addSubview(estimatedDateLabel)
    
    subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    subtitleLabel.adjustsFontForContentSizeCategory = true
    subtitleLabel.numberOfLines = 3
    
    addingDateLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    addingDateLabel.adjustsFontForContentSizeCategory = true
    addingDateLabel.textColor = .secondaryLabel
    addingDateLabel.lineBreakMode = .byTruncatingMiddle
    
    estimatedDateLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    estimatedDateLabel.adjustsFontForContentSizeCategory = true
    estimatedDateLabel.textColor = .secondaryLabel
    estimatedDateLabel.lineBreakMode = .byTruncatingMiddle
    
    promocodeView.layer.cornerRadius = 7
    
    imageView.backgroundColor = .systemGray3
    imageView.layer.maskedCorners = [.layerMaxXMaxYCorner]
    imageView.layer.cornerRadius = 8
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    
    let spacing = CGFloat(10)
    
    NSLayoutConstraint.activate([
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
      addingDateLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing / 2),
      addingDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing / 2),
      
      estimatedDateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.centerXAnchor, constant: spacing),
      estimatedDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
      estimatedDateLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing / 2),
      estimatedDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing / 2)
    ])
  }
}

  //MARK: - CellWithImageProtocol
extension ShopPlainCollectionViewCell: CellWithImage {
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
    imageView.image = nil
    imageView.backgroundColor = .systemGray3
  }
}
