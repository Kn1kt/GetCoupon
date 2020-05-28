//
//  SearchSuggestionCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 27.05.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class SearchSuggestionCollectionViewCell: UICollectionViewCell {
  
  static let reuseIdentifier = "search-suggestion-cell-reuse-identifier"
  
  let titleLabel = UILabel()
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
extension SearchSuggestionCollectionViewCell {
  
  func setupLayouts() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    separatorView.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(titleLabel)
    contentView.addSubview(separatorView)
    contentView.clipsToBounds = true
    
//    contentView.backgroundColor = .secondarySystemGroupedBackground
    
    selectedBackgroundView = UIView()
    selectedBackgroundView?.backgroundColor = UIColor.systemGray.withAlphaComponent(0.4)
    
    separatorView.backgroundColor = .systemGray4
    
    titleLabel.font = UIFont.preferredFont(forTextStyle: .title3)
    titleLabel.textColor = UIColor(named: "BlueTintColor")
    titleLabel.adjustsFontForContentSizeCategory = true
    
    let spacing = CGFloat(10)
    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
//      titleLabel.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 0.3),
      titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      
      separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
      separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
      separatorView.heightAnchor.constraint(equalToConstant: 0.5)
    ])
  }
}

  //MARK: - Prepare For Reuse
extension SearchSuggestionCollectionViewCell {
  
  override func prepareForReuse() {
    separatorView.isHidden = false
  }
}
