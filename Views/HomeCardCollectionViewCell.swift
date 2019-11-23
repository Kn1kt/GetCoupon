//
//  CollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class HomeCardCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "home-card-cell-reuse-identifier"
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let backView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
}

extension HomeCardCollectionViewCell {
    
    func setupLayouts() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        backView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(backView)
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 6
        
        backView.addSubview(imageView)
        backView.addSubview(titleLabel)
        backView.addSubview(subtitleLabel)
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        //titleLabel.textColor = .systemRed
        //titleLabel.allowsDefaultTighteningForTruncation = true
        titleLabel.adjustsFontForContentSizeCategory = true
        //titleLabel.adjustsFontSizeToFitWidth = true
        
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        subtitleLabel.numberOfLines = 2
        //subtitleLabel.allowsDefaultTighteningForTruncation = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        //subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.textColor = .placeholderText
        
        contentView.layer.cornerRadius = 6
        contentView.layer.shadowColor = UIColor.systemGray.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 5)
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowRadius = 5
        contentView.clipsToBounds = false
        contentView.backgroundColor = .secondarySystemGroupedBackground
        
        imageView.backgroundColor = .systemGray3
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        let spacing = CGFloat(10)
        
        if contentView.frame.height * 0.375 < 50 {
            subtitleLabel.isHidden = true
            titleLabel.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -spacing).isActive = true
        } else {
            NSLayoutConstraint.activate([
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
                subtitleLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: spacing),
                subtitleLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -spacing),
                subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: backView.bottomAnchor, constant: -spacing)
            ])
        }
        
        NSLayoutConstraint.activate([
            
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: backView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: backView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: backView.topAnchor),
            imageView.heightAnchor.constraint(equalTo: backView.heightAnchor, multiplier: 0.625),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing),
            titleLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: spacing),
            titleLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -spacing),
            //titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
//            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
//            subtitleLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: spacing),
//            subtitleLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -spacing),
//            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: backView.bottomAnchor, constant: -spacing)
        ])
    }
}
