//
//  FavoritesPlainCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 28.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class FavoritesPlainCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "favorites-plain-cell-reuse-identifier"
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let favoritesButton = AddToFavoritesButton()
    
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
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        //titleLabel.allowsDefaultTighteningForTruncation = true
        titleLabel.adjustsFontForContentSizeCategory = true
        
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        //subtitleLabel.allowsDefaultTighteningForTruncation = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .placeholderText
        
        
        //contentView.layer.cornerRadius = 6
        contentView.clipsToBounds = true
        //contentView.backgroundColor = .secondarySystemGroupedBackground
        
        imageView.layer.cornerRadius = 6
        imageView.backgroundColor = .systemGray3
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        let spacing = CGFloat(10)
        
        // iPad constrains need update
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.625),
            
            
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor),
            titleLabel.topAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 1.0),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
            //titleLabel.trailingAnchor.constraint(equalTo: favoritesButton.leadingAnchor, constant: -spacing),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
            titleLabel.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 0.15),
            
            favoritesButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
            //favoritesButton.topAnchor.constraint(equalToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 1.0),
            favoritesButton.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.0),
            favoritesButton.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, multiplier: 1.0),
            favoritesButton.widthAnchor.constraint(equalTo: favoritesButton.heightAnchor, multiplier: 1.0),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
            //subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -spacing)
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: subtitleLabel.bottomAnchor, multiplier: 1.0)
            
        ])
        
    }
}
