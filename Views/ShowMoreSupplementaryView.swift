//
//  FooterSupplementaryView.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 19.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ShowMoreSupplementaryView: UICollectionReusableView {
        
    let showMoreButton = ShowMoreUIButton()
    
    static let reuseIdentifier = "show-more-supplementory-reuse-identifier"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not Implemented")
    }
    
}

extension ShowMoreSupplementaryView {
    
    func setupLayouts() {
        addSubview(showMoreButton)
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = 6
        backgroundColor = .secondarySystemGroupedBackground
        
        NSLayoutConstraint.activate([
            showMoreButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            showMoreButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            showMoreButton.topAnchor.constraint(equalTo: topAnchor),
            showMoreButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
