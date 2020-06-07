//
//  HomeDetailCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 22.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class HomeDetailCollectionViewCell: UICollectionViewCell {
  
  var disposeBag = DisposeBag()
  
  static let reuseIdentifier = "home-detail-cell-reuse-identifier"
  
  let imageView = UIImageView()
  let titleLabel = UILabel()
  let subtitleLabel = UILabel()
  let separatorView = UIView()
  let addToFavoritesButton = AddToFavoritesButton()
  
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
extension HomeDetailCollectionViewCell {
  
  func setupLayouts() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    separatorView.translatesAutoresizingMaskIntoConstraints = false
    addToFavoritesButton.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(imageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(subtitleLabel)
    contentView.addSubview(separatorView)
    contentView.addSubview(addToFavoritesButton)
    
    backgroundColor = .secondarySystemGroupedBackground
    selectedBackgroundView = UIView()
    selectedBackgroundView?.backgroundColor = UIColor.systemGray.withAlphaComponent(0.4)
    clipsToBounds = true
    
    titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
    titleLabel.numberOfLines = 2
    titleLabel.adjustsFontForContentSizeCategory = true
    
    subtitleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
    subtitleLabel.numberOfLines = 3
    subtitleLabel.adjustsFontForContentSizeCategory = true
    subtitleLabel.textColor = .secondaryLabel
    
    imageView.layer.cornerRadius = 6
    imageView.backgroundColor = .systemGray3
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    
    separatorView.backgroundColor = .systemGray4
    
    titleHeight = titleLabel.heightAnchor.constraint(equalToConstant: titleLabel.font.lineHeight * 1.3)
    titleHeight.isActive = true
    
    let spacing = CGFloat(10)
    
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing * 1.5),
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing * 1.5),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing * 1.5),
      imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.3),
      
      addToFavoritesButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
      addToFavoritesButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
      addToFavoritesButton.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.113),
      addToFavoritesButton.widthAnchor.constraint(equalTo: addToFavoritesButton.heightAnchor, multiplier: 1.0),
      
      titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing * 2),
      titleLabel.trailingAnchor.constraint(equalTo: addToFavoritesButton.leadingAnchor, constant: -spacing * 2),
      titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: spacing * 0.8),
//      titleLabel.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 0.3),
//      titleLabel.heightAnchor.constraint(equalToConstant: titleLabel.font.lineHeight * 1.3),
      
      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing / 2),
      subtitleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing * 2),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing * 2),
      subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: imageView.bottomAnchor, constant: -spacing / 2),
      
      separatorView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing * 2),
      separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
      separatorView.heightAnchor.constraint(equalToConstant: 0.5)
    ])
  }
  
  override func layoutSubviews() {
    let titleSize = titleLabel.font.lineHeight * 1.3
    let subtitleSize = contentView.bounds.height - titleSize - 48
    titleHeight.constant = titleSize
    
    if subtitleSize < subtitleLabel.font.lineHeight {
      subtitleLabel.isHidden = true
    } else {
      subtitleLabel.isHidden = false
    }
  }
}


  //MARK: - CellWithImageProtocol
extension HomeDetailCollectionViewCell: CellWithImage {
  
  override func prepareForReuse() {
    disposeBag = DisposeBag()
    imageView.image = nil
    imageView.backgroundColor = .systemGray3
    separatorView.isHidden = false
    
    layer.maskedCorners = []
    layer.cornerRadius = 0
  }
}
