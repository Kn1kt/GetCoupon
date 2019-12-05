//
//  ShopData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 06.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ShopData {
    
    let name: String
    let description: String?
    let shortDescription: String
    
    let websiteLink: String
    
    let image: UIImage?
    let previewImage: UIImage?
    
    let promocodes: [PromocodeData]
    
    let identifier = UUID()
    
    init(name: String,
         description: String? = nil,
         shortDescription: String,
         websiteLink: String,
         image: UIImage? = nil,
         previewImage: UIImage? = nil,
         promocodes: [PromocodeData] = []) {
        self.name = name
        self.description = description
        self.shortDescription = shortDescription
        self.websiteLink = websiteLink
        self.image = image
        self.previewImage = previewImage
        self.promocodes = promocodes
        
    }
}

// MARK: - Hashable
extension ShopData: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: ShopData, rhs: ShopData) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
