//
//  LogoWithFavoritesButton.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 08.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class LogoWithFavoritesButton: UIView {

    let imageView = UIImageView()
    let favoritesButton = AddToFavoritesButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func layoutSubviews() {
        setupLayouts()
    }

}

extension LogoWithFavoritesButton {
    
    func setupLayouts() {
        
        addSubview(imageView)
        addSubview(favoritesButton)
        
        imageView.backgroundColor = .systemGray3
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        favoritesButton.backgroundColor = .secondarySystemGroupedBackground
        favoritesButton.clipsToBounds = true
        
        layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowOpacity = 1
        layer.shadowRadius = 28
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        favoritesButton.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        favoritesButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        favoritesButton.layer.shadowOpacity = 1
        favoritesButton.layer.shadowRadius = 28
        favoritesButton.layer.shouldRasterize = true
        favoritesButton.layer.rasterizationScale = UIScreen.main.scale
        
        imageView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        let side = frame.size.height * 0.3
        favoritesButton.frame = CGRect(x: bounds.size.width - side, y: bounds.size.height - side, width: side, height: side)
        
        layer.cornerRadius = bounds.size.height * 0.5
        imageView.layer.cornerRadius = imageView.bounds.size.height * 0.5
        favoritesButton.layer.cornerRadius = favoritesButton.bounds.height * 0.5
    }
}

    //MARK: - CellWithImageProtocol
extension LogoWithFavoritesButton: CellWithImage {}
