//
//  SegmentedControlCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 28.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class SegmentedControlCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "segmented-control-cell-reuse-identifier"
    
    let segmentedControl = UISegmentedControl(items: ["By sections","By dates"])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

    // MARK: - Layouts

extension SegmentedControlCollectionViewCell {
    
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
