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
    
//    // MARK: - Codable
//    private enum CodingKeys: String, CodingKey {
//        case name
//        case shopDescription
//        case shopShortDescription
//        case isHot
//        case websiteLink
//        //case imageURL
//        case imageLink
//        //case previewImageURL
//        case previewImageLink
//        case placeholderColor
//        case isFavorite
//        case favoriteAddingDate
//        case promoCodes
//    }
//
//    required convenience init(from decoder: Decoder) throws {
//        self.init()
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.name = try container.decode(String.self, forKey: .name)
//        self.shopDescription = try container.decode(String?.self, forKey: .shopDescription)
//        self.shopShortDescription = try container.decode(String.self, forKey: .shopShortDescription)
//        self.isHot = try container.decode(Bool.self, forKey: .isHot)
//        self.websiteLink = try container.decode(String.self, forKey: .websiteLink)
//        self.imageLink = try container.decode(String.self, forKey: .imageLink)
//        self.previewImageLink = try container.decode(String.self, forKey: .previewImageLink)
//        self.isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
//        self.favoriteAddingDate = try container.decode(Date?.self, forKey: .favoriteAddingDate)
//
//        let components = try container.decode([Float].self, forKey: .placeholderColor)
//        self.placeholderColor.append(objectsIn: components)
//
//        let promoCodes = try container.decode([PromoCodeStoredData].self, forKey: .promoCodes)
//        self.promoCodes.append(objectsIn: promoCodes)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(name, forKey: .name)
//        try container.encode(shopDescription, forKey: .shopDescription)
//        try container.encode(shopShortDescription, forKey: .shopShortDescription)
//        try container.encode(isHot, forKey: .isHot)
//        try container.encode(websiteLink, forKey: .websiteLink)
//        try container.encode(imageLink, forKey: .imageLink)
//        try container.encode(previewImageLink, forKey: .previewImageLink)
//        try container.encode(placeholderColor, forKey: .placeholderColor)
//        try container.encode(isFavorite, forKey: .isFavorite)
//        try container.encode(favoriteAddingDate, forKey: .favoriteAddingDate)
//        try container.encode(promoCodes, forKey: .promoCodes)
//    }
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
