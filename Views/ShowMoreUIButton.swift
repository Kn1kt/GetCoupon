//
//  ShowMoreUIButton.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 20.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ShowMoreUIButton: UIButton {

    var sectionIndex: Int?
    
    init() {
        super.init(frame: .zero)
        
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        setTitle("Show all shops in category", for: .normal)
        setTitleColor(UIColor(named: "BlueTintColor"), for: .normal)
        setTitleColor(.systemGray, for: .highlighted)
        titleLabel?.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
