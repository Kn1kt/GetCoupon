//
//  ShopStoredData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 11.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import Foundation
import RealmSwift

class ShopStoredData: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var shopDescription: String? = nil
    @objc dynamic var shopShortDescription: String = ""
    
    @objc dynamic var websiteLink: String = ""
    
    @objc dynamic var imageURL: String? = nil
    @objc dynamic var imageLink: String = ""
    
    @objc dynamic var previewImageURL: String? = nil
    @objc dynamic var previewImageLink: String = ""
    
    let placeholderColor = List<Float>()
    
    @objc dynamic var isFavorite: Bool = false
    @objc dynamic var favoriteAddingDate: Date? = nil
    
    let promoCodes = List<PromoCodeStoredData>()
    
    convenience init(name: String,
                     description: String? = nil,
                     shortDescription: String,
                     websiteLink: String,
                     imageLink: String = "",
                     previewImageLink: String = "",
                     placeholderColor: UIColor = .systemGray3,
                     isFavorite: Bool = false,
                     promoCodes: [PromoCodeStoredData] = []) {
        self.init()
        self.name = name
        self.shopDescription = description
        self.shopShortDescription = shortDescription
        self.websiteLink = websiteLink
        self.imageLink = imageLink
        self.previewImageLink = previewImageLink
        self.isFavorite = isFavorite
        
        placeholderColor.cgColor.components?.forEach {
            let floatDigit = Float($0)
            self.placeholderColor.append(floatDigit)
        }
        
        promoCodes.forEach {
            self.promoCodes.append($0)
        }
    }
    
    override static func primaryKey() -> String? {
        return "name"
    }
}
