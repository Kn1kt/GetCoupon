//
//  HomeDetailCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 22.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class HomeDetailCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "home-detail-cell-reuse-identifier"
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let separatorView = UIView()
    let addToFavoritesButton = AddToFavoritesButton()
    
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
        contentView.clipsToBounds = true
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        
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
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.5),
            
            //addToFavoritesButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: spacing),
            addToFavoritesButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
            //addToFavoritesButton.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.5),
            addToFavoritesButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addToFavoritesButton.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, multiplier: 2.0),
            addToFavoritesButton.widthAnchor.constraint(equalTo: addToFavoritesButton.heightAnchor, multiplier: 1.0),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing),
            titleLabel.trailingAnchor.constraint(equalTo: addToFavoritesButton.leadingAnchor, constant: -spacing),
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.5),
            titleLabel.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 0.3),
            
            subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: addToFavoritesButton.bottomAnchor, multiplier: 1.0),
            subtitleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}


    //MARK: - CellWithImageProtocol
extension HomeDetailCollectionViewCell: CellWithImage {
    
    override func prepareForReuse() {
        imageView.image = nil
        imageView.backgroundColor = .systemGray3
        separatorView.isHidden = false
     }
}
