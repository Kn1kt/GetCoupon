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
    let backView = UIView()
    
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
        backView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(backView)
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 6
        backView.frame = contentView.frame
        backView.backgroundColor = .secondarySystemGroupedBackground
        
        backView.addSubview(imageView)
        backView.addSubview(titleLabel)
        backView.addSubview(subtitleLabel)
        backView.addSubview(favoritesButton)
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true
        
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryLabel
        
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 10)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 15
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.main.scale
        
        imageView.backgroundColor = .systemGray3
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        let spacing = CGFloat(10)
        
        // iPad constrains need update
        NSLayoutConstraint.activate([
            
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: backView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: backView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: backView.topAnchor),
            imageView.heightAnchor.constraint(equalTo: backView.heightAnchor, multiplier: 0.625),
            
            
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor),
            titleLabel.topAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 1.0),
            titleLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: spacing),
            titleLabel.trailingAnchor.constraint(equalTo: favoritesButton.leadingAnchor, constant: -spacing),
            titleLabel.heightAnchor.constraint(lessThanOrEqualTo: backView.heightAnchor, multiplier: 0.15),
            
            favoritesButton.trailingAnchor.constraint(equalTo: backView.trailingAnchor),
            favoritesButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            favoritesButton.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, multiplier: 2.0),
            favoritesButton.widthAnchor.constraint(equalTo: favoritesButton.heightAnchor, multiplier: 1.0),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: spacing),
            subtitleLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -spacing),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: subtitleLabel.bottomAnchor, multiplier: 1.0)
            
        ])
        
    }
}

    //MARK: - CellWithImageProtocol
extension FavoritesPlainCollectionViewCell: CellWithImage {
    
    override func prepareForReuse() {
        imageView.image = nil
        imageView.backgroundColor = .systemGray3
    }
}
