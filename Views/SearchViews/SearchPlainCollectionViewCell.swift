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
    
    titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
    titleLabel.adjustsFontForContentSizeCategory = true
    
    subtitleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    subtitleLabel.numberOfLines = 2
    subtitleLabel.adjustsFontForContentSizeCategory = true
    subtitleLabel.textColor = .secondaryLabel
    
    imageView.layer.cornerRadius = 8
    imageView.backgroundColor = .systemGray3
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    
    separatorView.backgroundColor = .systemGray4

    titleHeight = titleLabel.heightAnchor.constraint(equalToConstant: titleLabel.font.lineHeight * 1.2)
    titleHeight.isActive = true
    
    let spacing = CGFloat(10)
    
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing),
      imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0),
      
      titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing * 2),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing * 2),
      titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: spacing / 2),
//      titleLabel.heightAnchor.constraint(equalToConstant: titleLabel.font.lineHeight * 1.3),
      
      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing / 2),
      subtitleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing * 2),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing * 2),
      subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: imageView.bottomAnchor, constant: -spacing / 2),
      
      separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
      separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
      separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      separatorView.heightAnchor.constraint(equalToConstant: 0.5)
    ])
  }
  
  override func layoutSubviews() {
    let titleSize = titleLabel.font.lineHeight * 1.2
    let subtitleSize = contentView.bounds.height - titleSize - 35
    titleHeight.constant = titleSize
    
    if subtitleSize < subtitleLabel.font.lineHeight {
      subtitleLabel.isHidden = true
    } else {
      subtitleLabel.isHidden = false
    }
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
