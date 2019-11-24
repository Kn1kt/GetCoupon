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
    let likeButton = LikeImageView()
    
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
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(separatorView)
        contentView.addSubview(likeButton)
        contentView.clipsToBounds = true
        
//        selectedBackgroundView = UIView()
//        selectedBackgroundView?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        
        separatorView.backgroundColor = .systemGray4
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true
        
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        subtitleLabel.numberOfLines = 2
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .placeholderText
        
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = .systemGray3
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        likeButton.image = UIImage(systemName: "heart")
        likeButton.highlightedImage = UIImage(systemName: "heart.fill")
        likeButton.tintColor = .systemGray4
        
        let spacing = CGFloat(10)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            //likeButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: spacing),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing * 2),
            likeButton.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.5),
            likeButton.heightAnchor.constraint(equalTo: titleLabel.heightAnchor),
            likeButton.widthAnchor.constraint(equalTo: likeButton.heightAnchor, multiplier: 1.1),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing),
            titleLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -spacing),
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.5),
            
            subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),
            subtitleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
            
            separatorView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
