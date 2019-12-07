//
//  SearchPlainCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 04.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class SearchPlainCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "home-detail-cell-reuse-identifier"
        
        let imageView = UIImageView()
        let titleLabel = UILabel()
        let subtitleLabel = UILabel()
        let separatorView = UIView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupLayouts()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func prepareForReuse() {
            separatorView.isHidden = false
        }
    }

    // MARK: - Layouts

    extension SearchPlainCollectionViewCell {
        
        func setupLayouts() {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(imageView)
            contentView.addSubview(titleLabel)
            contentView.addSubview(subtitleLabel)
            contentView.addSubview(separatorView)
            contentView.clipsToBounds = true
            
    //        selectedBackgroundView = UIView()
    //        selectedBackgroundView?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            
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
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0),
                
                titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
                titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.5),
                titleLabel.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 0.3),
                
                subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),
                subtitleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing),
                subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
                
                separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
                separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
                separatorView.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
}
