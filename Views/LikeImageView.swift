//
//  likeImageView.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 24.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class LikeImageView: UIImageView {
  
  override var isHighlighted: Bool {
    willSet {
      if newValue {
        tintColor = .systemRed
      } else {
        tintColor = .systemGray4
      }
    }
  }
}

