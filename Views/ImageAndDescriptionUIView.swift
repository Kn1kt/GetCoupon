//
//  ImageAndDescriptionUIView.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 08.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ImageAndDescriptionUIView: UIView {

    let imageView = UIImageView()
    let imageDescription = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
}

extension ImageAndDescriptionUIView {
    
    func setupLayouts() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageDescription.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        addSubview(imageDescription)
        
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        
        imageDescription.font = UIFont.preferredFont(forTextStyle: .body)
        imageDescription.adjustsFontForContentSizeCategory = true
        imageDescription.textColor = .tertiaryLabel
        imageDescription.textAlignment = .center
        
        let spacing = CGFloat(10)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            imageDescription.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            imageDescription.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            imageDescription.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing),
            imageDescription.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageDescription.centerXAnchor.constraint(equalTo: centerXAnchor)
            
        ])
    }
}
