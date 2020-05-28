//
//  SearchPlainCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 04.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class SearchPlainCollectionViewCell: UICollectionViewCell {
  
  var disposeBag = DisposeBag()
  static let reuseIdentifier = "search-plain-cell-reuse-identifier"
  
  let imageView = UIImageView()
  let titleLabel = UILabel()
  let subtitleLabel = UILabel()
  let separatorView = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

  // MARK: - Layouts
extension SearchPlainCollectionViewCell {
  
  func setupLayouts() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    separatorView.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(imageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(subtitleLabel)
    contentView.addSubview(separatorView)
    contentView.clipsToBounds = true
    
    backgroundColor = .secondarySystemGroupedBackground
    
    selectedBackgroundView = UIView()
    selectedBackgroundView?.backgroundColor = UIColor.systemGray.withAlphaComponent(0.4)
    clipsToBounds = true
    
    separatorView.backgroundColor = .systemGray4
    
    titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
    titleLabel.adjustsFontForContentSizeCategory = true
    
    subtitleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
    subtitleLabel.numberOfLines = 2
    subtitleLabel.adjustsFontForContentSizeCategory = true
    subtitleLabel.textColor = .secondaryLabel
    
    imageView.layer.cornerRadius = 6
    imageView.backgroundColor = .systemGray3
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    
    let spacing = CGFloat(10)
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing),
      imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0),
      
      titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
      titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: spacing * 0.8),
      titleLabel.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 0.3),
      
      subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),
      subtitleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
      
      separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
      separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
      separatorView.heightAnchor.constraint(equalToConstant: 0.5)
    ])
  }
}

  //MARK: - CellWithImageProtocol
extension SearchPlainCollectionViewCell: CellWithImage {
  
  override func prepareForReuse() {
    imageView.image = nil
    imageView.backgroundColor = .systemGray3
    layer.maskedCorners = []
    layer.cornerRadius = 0
    separatorView.isHidden = false
    disposeBag = DisposeBag()
  }
}
