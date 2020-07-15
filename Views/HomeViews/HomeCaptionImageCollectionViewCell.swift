//
//  HomeCaptionImageCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 20.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class HomeCaptionImageCollectionViewCell: UICollectionViewCell {
  
  var disposeBag = DisposeBag()
  
  static let reuseIdentifier = "home-caption-image-cell-reuse-identifier"
  
  let imageView = UIImageView()
  let titleLabel = UILabel()
  let subtitleLabel = UILabel()
  
  private var titleHeight: NSLayoutConstraint!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

  // MARK: - Layouts
extension HomeCaptionImageCollectionViewCell {
  
  func setupLayouts() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(imageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(subtitleLabel)
    
    selectedBackgroundView = UIView()
    selectedBackgroundView?.backgroundColor = UIColor.systemGray.withAlphaComponent(0.4)
    layer.cornerRadius = 7
    clipsToBounds = true
    
    titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
    titleLabel.adjustsFontForContentSizeCategory = true
    
    subtitleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    subtitleLabel.adjustsFontForContentSizeCategory = true
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.numberOfLines = 2
    
    imageView.layer.cornerRadius = 8
    imageView.backgroundColor = .systemGray3
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    
    titleHeight = titleLabel.heightAnchor.constraint(equalToConstant: titleLabel.font.lineHeight * 1.2)
    titleHeight.isActive = true
    
    let spacing = CGFloat(5)
    
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//      imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.625),
      imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
      
      titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
//      titleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.15),
//      titleLabel.heightAnchor.constraint(equalToConstant: titleLabel.font.lineHeight * 1.3),
      
      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
      subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
      subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing)
//      subtitleLabel.heightAnchor.constraint(equalToConstant: subtitleLabel.font.lineHeight * 2.5)
//      subtitleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.2)
    ])
  }
  
  override func layoutSubviews() {
    let titleSize = titleLabel.font.lineHeight * 1.2
    let subtitleSize = contentView.bounds.height * 0.4 - titleSize - 10
    titleHeight.constant = titleSize
    
    if subtitleSize < subtitleLabel.font.lineHeight {
      subtitleLabel.isHidden = true
    } else {
      subtitleLabel.isHidden = false
    }
  }
}

  //MARK: - CellWithImageProtocol
extension HomeCaptionImageCollectionViewCell: CellWithImage {
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
    imageView.image = nil
    imageView.backgroundColor = .systemGray3
  }
}
