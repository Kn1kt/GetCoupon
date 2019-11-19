//
//  HomeCaptionImageCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 20.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class HomeCaptionImageCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "home-caption-image-cell-reuse-identifier"
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
}

extension HomeCaptionImageCollectionViewCell {
    
    func setupLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        titleLabel.adjustsFontForContentSizeCategory = true
        
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
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
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100.0),
            
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing)
        ])
        
    }
}
