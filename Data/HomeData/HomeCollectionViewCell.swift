//
//  CollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "home-cell-reuse-identifier"
    
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

extension HomeCollectionViewCell {
    
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
        
        
        contentView.layer.cornerRadius = 6
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemGroupedBackground
        
        imageView.backgroundColor = #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1)
        
        let spacing = CGFloat(10)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
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
