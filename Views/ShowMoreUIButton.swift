//
//  ShowMoreUIButton.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 20.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ShowMoreUIButton: UIButton {
  
  var sectionTitle: String?
  
  init() {
    super.init(frame: .zero)
    
    titleLabel?.adjustsFontForContentSizeCategory = true
    titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
    setTitle(NSLocalizedString("see-all", comment: "See All"), for: .normal)
    setTitleColor(UIColor(named: "BlueTintColor"), for: .normal)
    setTitleColor(.systemGray, for: .highlighted)
    titleLabel?.textAlignment = .right
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
