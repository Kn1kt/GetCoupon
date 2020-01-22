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
    @objc dynamic var shopDescription: String?
    @objc dynamic var shopShortDescription: String = ""
    @objc dynamic var isHot: Bool = false
    
    @objc dynamic var websiteLink: String = ""
    
    @objc dynamic var imageURL: String?
    @objc dynamic var imageLink: String = ""
    
    @objc dynamic var previewImageURL: String?
    @objc dynamic var previewImageLink: String = ""
    
    let placeholderColor = List<Float>()
    
    @objc dynamic var isFavorite: Bool = false
    @objc dynamic var favoriteAddingDate: Date?
    
    let promoCodes = List<PromoCodeStoredData>()
    
    convenience init(name: String,
                     description: String? = nil,
                     shortDescription: String,
                     isHot: Bool = false,
                     websiteLink: String,
                     imageLink: String = "",
                     previewImageLink: String = "",
                     placeholderColor: [Float] = [],
                     promoCodes: [PromoCodeStoredData] = []) {
        self.init()
        self.name = name
        self.shopDescription = description
        self.shopShortDescription = shortDescription
        self.isHot = isHot
        self.websiteLink = websiteLink
        self.imageLink = imageLink
        self.previewImageLink = previewImageLink
        
        self.placeholderColor.append(objectsIn: placeholderColor)
        
        self.promoCodes.append(objectsIn: promoCodes)
    }
    
    override static func primaryKey() -> String? {
        return "name"
    }
}

    // MARK: - NetworkShopData Compatible
extension ShopStoredData {
    
    convenience init(_ networkShop: NetworkShopData) {
        self.init(name: networkShop.name,
                  description: networkShop.shopDescription,
                  shortDescription: networkShop.shopShortDescription,
                  isHot: networkShop.isHot,
                  websiteLink: networkShop.websiteLink,
                  imageLink: networkShop.imageLink,
                  previewImageLink: networkShop.previewImageLink,
                  placeholderColor: networkShop.placeholderColor,
                  promoCodes: networkShop.promoCodes.map(PromoCodeStoredData.init))
    }
}