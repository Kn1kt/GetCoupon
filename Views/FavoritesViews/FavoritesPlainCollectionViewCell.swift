//
//  FavoritesPlainCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 28.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class FavoritesPlainCollectionViewCell: UICollectionViewCell {
  
  var disposeBag = DisposeBag()
  
  static let reuseIdentifier = "favorites-plain-cell-reuse-identifier"
  
  let imageView = UIImageView()
  let titleLabel = UILabel()
  let subtitleLabel = UILabel()
  let favoritesButton = AddToFavoritesButton()
  
  private var titleHeight: NSLayoutConstraint!
  private var subtitleHeight: NSLayoutConstraint!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

  // MARK: - Layouts
extension FavoritesPlainCollectionViewCell {
  
  func setupLayouts() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    favoritesButton.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(imageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(subtitleLabel)
    contentView.addSubview(favoritesButton)
    
    selectedBackgroundView = UIView()
    selectedBackgroundView?.backgroundColor = UIColor.systemGray.withAlphaComponent(0.4)
    
    clipsToBounds = true
    layer.cornerRadius = 10
    backgroundColor = .secondarySystemGroupedBackground
    
    titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
    titleLabel.adjustsFontForContentSizeCategory = true
    
    subtitleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    subtitleLabel.adjustsFontForContentSizeCategory = true
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.numberOfLines = 2
    
    imageView.backgroundColor = .systemGray3
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    
    titleHeight = titleLabel.heightAnchor.constraint(equalToConstant: titleLabel.font.lineHeight * 1.2)
    titleHeight.isActive = true

    subtitleHeight = subtitleLabel.heightAnchor.constraint(equalToConstant: subtitleLabel.font.lineHeight * 2.5)
    subtitleHeight.isActive = true
    
    let spacing = CGFloat(10)
    
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//      imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.625),
      
      
//      titleLabel.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor),
//      titleLabel.topAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 1.0),
      titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing / 2),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
      titleLabel.trailingAnchor.constraint(equalTo: favoritesButton.leadingAnchor, constant: -spacing),
//      titleLabel.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 0.15),
//      titleLabel.heightAnchor.constraint(equalToConstant: titleLabel.font.lineHeight * 1.3),
      
      favoritesButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      favoritesButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
      favoritesButton.heightAnchor.constraint(equalTo: favoritesButton.widthAnchor, multiplier: 1.0),
      favoritesButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.232),
      
      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
      subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
//      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: subtitleLabel.bottomAnchor, multiplier: 1.0)
      subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing / 2),
//      subtitleLabel.heightAnchor.constraint(equalToConstant: subtitleLabel.font.lineHeight * 2.5)
    ])
  }
  
  override func layoutSubviews() {
    let halfOfView = contentView.bounds.height / 2
    let titleConst = titleLabel.font.lineHeight * 1.2
    let subtitleConst = subtitleLabel.font.lineHeight * 2.5
    
    titleHeight.constant = titleConst < halfOfView ? titleConst : halfOfView
    subtitleHeight.constant = subtitleConst < halfOfView ? subtitleConst : halfOfView
  }
}

  //MARK: - CellWithImageProtocol
extension FavoritesPlainCollectionViewCell: CellWithImage {
  
  override func prepareForReuse() {
    disposeBag = DisposeBag()
    imageView.image = nil
    imageView.backgroundColor = .systemGray3
  }
}
