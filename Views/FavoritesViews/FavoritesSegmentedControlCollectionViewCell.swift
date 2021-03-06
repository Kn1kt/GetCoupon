//
//  SegmentedControlCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 28.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class FavoritesSegmentedControlCollectionViewCell: UICollectionViewCell {
  
  var disposeBag = DisposeBag()
  
  static let reuseIdentifier = "favorites-segmented-control-cell-reuse-identifier"
  
  let segmentedControl = UISegmentedControl(items: [NSLocalizedString("by-sections", comment: "by Sections"), NSLocalizedString("by-dates", comment: "by Dates")])
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

  // MARK: - Layouts
extension FavoritesSegmentedControlCollectionViewCell {
  
  func setupLayouts() {
    
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    segmentedControl.selectedSegmentIndex = 0
    
    contentView.addSubview(segmentedControl)
    
    contentView.clipsToBounds = true
    
    NSLayoutConstraint.activate([
      segmentedControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      segmentedControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      segmentedControl.widthAnchor.constraint(equalTo: contentView.widthAnchor),
      segmentedControl.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8)
    ])
  }
}

extension FavoritesSegmentedControlCollectionViewCell {
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
}
