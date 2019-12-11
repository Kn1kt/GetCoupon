//
//  ShopData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 06.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ShopData: Codable {
    
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
    
    /// Codable
    private enum CodingKeys: String, CodingKey {
        case name
        case description
        case shortDescription
        case websiteLink
        case image
        case previewImage
        case isFavorite
        case favoriteAddingDate
        case promocodes
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String?.self, forKey: .description)
        shortDescription = try container.decode(String.self, forKey: .shortDescription)
        websiteLink = try container.decode(String.self, forKey: .websiteLink)
        image = try container.decode(UIImage?.self, forKey: .image)
        previewImage = try container.decode(UIImage?.self, forKey: .previewImage)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        favoriteAddingDate = try container.decode(Date?.self, forKey: .favoriteAddingDate)
        promocodes = try container.decode([PromocodeData].self, forKey: .promocodes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(shortDescription, forKey: .shortDescription)
        try container.encode(websiteLink, forKey: .websiteLink)
        try container.encode(image, forKey: .image)
        try container.encode(previewImage, forKey: .previewImage)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(favoriteAddingDate, forKey: .favoriteAddingDate)
        try container.encode(promocodes, forKey: .promocodes)
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

    // MARK: - Codable
extension KeyedEncodingContainer {

    mutating func encode(_ value: UIImage?,
                         forKey key: KeyedEncodingContainer.Key) throws {
        let imageData = value?.pngData()
        try encode(imageData, forKey: key)
    }

}

extension KeyedDecodingContainer {

    public func decode(_ type: UIImage?.Type,
                       forKey key: KeyedDecodingContainer.Key) throws -> UIImage? {
        let imageData = try decode(Data.self, forKey: key)
        if let image = UIImage(data: imageData) {
            return image
        } else {
            return nil
        }
    }

}
