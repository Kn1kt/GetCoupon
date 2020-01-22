//
//  ShopCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 07.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ShopPlainCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "shop-plain-cell-reuse-identifier"
    
    let imageView = UIImageView()
    //let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    //let couponLabel = UILabel()
    let promocodeView = PromocodeView()
    let addingDateLabel = UILabel()
    let estimatedDateLabel = UILabel()
    let backView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
}

extension ShopPlainCollectionViewCell {
    
    func setupLayouts() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        //couponLabel.translatesAutoresizingMaskIntoConstraints = false
        promocodeView.translatesAutoresizingMaskIntoConstraints = false
        addingDateLabel.translatesAutoresizingMaskIntoConstraints = false
        estimatedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        backView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(backView)
        
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 6
        //backView.frame = contentView.frame
        
        backView.addSubview(imageView)
        //backView.addSubview(titleLabel)
        backView.addSubview(subtitleLabel)
        //backView.addSubview(couponLabel)
        backView.addSubview(promocodeView)
        backView.addSubview(addingDateLabel)
        backView.addSubview(estimatedDateLabel)
        backView.backgroundColor = .secondarySystemGroupedBackground
        
        //titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        //titleLabel.adjustsFontForContentSizeCategory = true
        
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        //subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 3
        
        addingDateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        addingDateLabel.adjustsFontForContentSizeCategory = true
        addingDateLabel.textColor = .tertiaryLabel
        
        estimatedDateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        estimatedDateLabel.adjustsFontForContentSizeCategory = true
        estimatedDateLabel.textColor = .tertiaryLabel
        
//        couponLabel.font = UIFont.preferredFont(forTextStyle: .body)
//        couponLabel.adjustsFontForContentSizeCategory = true
//        couponLabel.textAlignment = .center
//        couponLabel.layer.cornerRadius = 10
//        couponLabel.backgroundColor = #colorLiteral(red: 0.2273195386, green: 0.4160661697, blue: 0.5951462388, alpha: 1)
//        couponLabel.clipsToBounds = true
//        couponLabel.textColor = .white
        
        promocodeView.layer.cornerRadius = 6
        
        
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 10)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 15
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.main.scale
        
        imageView.backgroundColor = .systemGray3
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        let spacing = CGFloat(10)
        
        NSLayoutConstraint.activate([
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: backView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: backView.topAnchor),
            imageView.heightAnchor.constraint(equalTo: backView.heightAnchor, multiplier: 0.75),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            //titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing * 1.5),
            //titleLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -spacing),
            //titleLabel.topAnchor.constraint(equalTo: backView.topAnchor, constant: spacing),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing * 1.5),
            subtitleLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -spacing),
            //subtitleLabel.firstBaselineAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing * 1.5),
            subtitleLabel.topAnchor.constraint(equalTo: backView.topAnchor, constant: spacing),
            subtitleLabel.bottomAnchor.constraint(equalTo: promocodeView.topAnchor, constant: -spacing),
            
            promocodeView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing * 1.5),
            promocodeView.trailingAnchor.constraint(lessThanOrEqualTo: backView.trailingAnchor, constant: -spacing),
            promocodeView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            promocodeView.heightAnchor.constraint(equalToConstant: 31),
            
            addingDateLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: spacing),
            addingDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: backView.centerXAnchor, constant: -spacing),
            addingDateLabel.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor),
            addingDateLabel.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -spacing),
            
            estimatedDateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backView.centerXAnchor, constant: spacing),
            estimatedDateLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -spacing),
            estimatedDateLabel.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor),
            estimatedDateLabel.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -spacing),
        ])
    }
}

    //MARK: - CellWithImageProtocol
extension ShopPlainCollectionViewCell: CellWithImage {
    
    override func prepareForReuse() {
        imageView.image = nil
        imageView.backgroundColor = .systemGray3
    }
}
