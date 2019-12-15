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
        backView.backgroundColor = .secondarySystemGroupedBackground
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true
        
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryLabel
        
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 5
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.main.scale
        
        imageView.backgroundColor = .systemGray3
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        let spacing = CGFloat(10)
        
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
            titleLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -spacing),
            
            subtitleLabel.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor),
            subtitleLabel.topAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 0.1),
            subtitleLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: spacing),
            subtitleLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -spacing),
            backView.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: subtitleLabel.bottomAnchor, multiplier: 1.0)
        ])
    }
}

    //MARK: - CellWithImageProtocol
extension HomeCardCollectionViewCell: CellWithImage {
    
    override func prepareForReuse() {
         imageView.image = nil
         imageView.backgroundColor = .systemGray3
     }
}
