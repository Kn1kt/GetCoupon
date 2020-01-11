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
    let button = UIButton()
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
        button.translatesAutoresizingMaskIntoConstraints = false
        
        //addSubview(imageView)
        addSubview(button)
        addSubview(imageDescription)
        button.addSubview(imageView)
        
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
//            imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
//            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4),
//            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            button.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4),
            button.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: button.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            
            imageDescription.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            imageDescription.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            imageDescription.topAnchor.constraint(equalTo: button.bottomAnchor, constant: spacing),
            imageDescription.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageDescription.centerXAnchor.constraint(equalTo: centerXAnchor)
            
        ])
    }
}
