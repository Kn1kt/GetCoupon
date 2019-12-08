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
    
    var isFavorite: Bool
    var favoriteAddingDate: Date?
    
    var promocodes: [PromocodeData]
    
    let identifier = UUID()
    
    init(name: String,
         description: String? = nil,
         shortDescription: String,
         websiteLink: String,
         image: UIImage? = nil,
         previewImage: UIImage? = nil,
         isFavorite: Bool = false,
         promocodes: [PromocodeData] = []) {
        self.name = name
        self.description = description
        self.shortDescription = shortDescription
        self.websiteLink = websiteLink
        self.image = image
        self.previewImage = previewImage
        self.promocodes = promocodes
        self.isFavorite = isFavorite
    }
    
    convenience init(image: UIImage?, name: String, shortDescription: String) {
        self.init(name: name,
        description: nil,
        shortDescription: shortDescription,
        websiteLink: "",
        image: image,
        previewImage: image,
        isFavorite: false,
        promocodes: [])
    }
    
    convenience init(name: String, shortDescription: String) {
        self.init(name: name,
        description: nil,
        shortDescription: shortDescription,
        websiteLink: "",
        image: nil,
        previewImage: nil,
        isFavorite: false,
        promocodes: [])
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
