//
//  SegmentedControlCoCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 04.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class HomeDetailSegmentedControlCollectionViewCell: UICollectionViewCell {
  
  var disposeBag = DisposeBag()
  
  static let reuseIdentifier = "home-detail-segmented-control-cell-reuse-identifier"
  
  let segmentedControl = UISegmentedControl(items: ["By popularity", "By dates"])
  let countLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    disposeBag = DisposeBag()
  }
}

// MARK: - Layouts

extension HomeDetailSegmentedControlCollectionViewCell {
  
  func setupLayouts() {
    
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    countLabel.translatesAutoresizingMaskIntoConstraints = false
    
    countLabel.font = UIFont.preferredFont(forTextStyle: .body)
    countLabel.adjustsFontForContentSizeCategory = true
    
    segmentedControl.selectedSegmentIndex = 0
    
    contentView.addSubview(segmentedControl)
    contentView.addSubview(countLabel)
    
    contentView.clipsToBounds = true
    
    let spacing = CGFloat(10)
    NSLayoutConstraint.activate([
      segmentedControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      segmentedControl.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
      segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      segmentedControl.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
      
      countLabel.leadingAnchor.constraint(greaterThanOrEqualTo: segmentedControl.trailingAnchor, constant: spacing),
      countLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing)
    ])
  }
}
