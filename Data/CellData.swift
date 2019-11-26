//
//  HomeCellData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class CellData: NSObject {
    
    var image: UIImage?
    let title: String
    let subtitle: String
    //let identifier = UUID()
    
    init(image: UIImage?, title: String, subtitle: String) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
    
    convenience init(title: String, subtitle: String) {
        self.init(image: nil, title: title, subtitle: subtitle)
    }
    
    @objc dynamic var isFavorite: Bool = false
    
    var favoriteAddingDate: Date?
}

//// MARK: - Hashable
//extension CellData: Hashable {
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(identifier)
//    }
//
//    static func == (lhs: CellData, rhs: CellData) -> Bool {
//        return lhs.identifier == rhs.identifier
//    }
//}
