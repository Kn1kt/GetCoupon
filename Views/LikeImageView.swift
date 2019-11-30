//
//  likeImageView.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 24.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class LikeImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override var isHighlighted: Bool {
        willSet {
            if newValue {
                tintColor = .systemRed
                //tintColor = .secondaryLabel
            } else {
                tintColor = .systemGray4
            }
        }
    }
}

