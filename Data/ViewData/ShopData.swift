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
    let isHot: Bool
    
    let websiteLink: String
    
    private var _image: UIImage? = nil
    private let imageQueue = DispatchQueue(label: "imageQueue", attributes: .concurrent)
    var image: UIImage? {
        get {
            imageQueue.sync {
                return _image
            }
        }
        
        set {
            imageQueue.async(flags: .barrier) { [weak self] in
                self?._image = newValue
            }
        }
    }
    
    //let imageLink: String
    
    private var _previewImage: UIImage? = nil
    private let previewImageQueue = DispatchQueue(label: "previewImageQueue", attributes: .concurrent)
    var previewImage: UIImage? {
        get {
            previewImageQueue.sync {
                return _previewImage
            }
        }
        
        set {
            previewImageQueue.async(flags: .barrier) { [weak self] in
                self?._previewImage = newValue
            }
        }
    }
    
    //let previewImageLink: String
    
    let placeholderColor: UIColor
    
    var isFavorite: Bool
    var favoriteAddingDate: Date?
    
    var promoCodes: [PromoCodeData]
    
    let identifier = UUID()
    
    init(name: String,
         description: String? = nil,
         shortDescription: String,
         isHot: Bool = false,
         websiteLink: String,
         //imageLink: String = "",
         //previewImageLink: String = "",
         placeholderColor: UIColor = .systemGray3,
         image: UIImage? = nil,
         previewImage: UIImage? = nil,
         isFavorite: Bool = false,
         favoriteAddingDate: Date? = nil,
         promoCodes: [PromoCodeData] = []) {
        self.name = name
        self.description = description
        self.shortDescription = shortDescription
        self.isHot = isHot
        self.websiteLink = websiteLink
        //self.imageLink = imageLink
        //self.previewImageLink = previewImageLink
        self.placeholderColor = placeholderColor
        self._image = image
        self._previewImage = previewImage
        self.promoCodes = promoCodes
        self.isFavorite = isFavorite
        self.favoriteAddingDate = favoriteAddingDate
    }
    
    convenience init(image: UIImage?, name: String, shortDescription: String, placeholderColor: UIColor) {
        self.init(name: name,
        description: nil,
        shortDescription: shortDescription,
        websiteLink: "",
        placeholderColor: placeholderColor,
        image: image,
        previewImage: image,
        isFavorite: false,
        promoCodes: [])
    }
    
    convenience init(name: String, shortDescription: String) {
        self.init(name: name,
        description: nil,
        shortDescription: shortDescription,
        websiteLink: "",
        image: nil,
        previewImage: nil,
        isFavorite: false,
        promoCodes: [])
    }
    
    /// Bridge for stored data
    convenience init(_ shop: ShopStoredData) {
        let color = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(),
                            components: Array(shop.placeholderColor).map(CGFloat.init))
        let promoCodes = Array(shop.promoCodes).map(PromoCodeData.init)
        
        self.init(name: shop.name,
        description: shop.shopDescription,
        shortDescription: shop.shopShortDescription,
        isHot: shop.isHot,
        websiteLink: shop.websiteLink,
        placeholderColor: UIColor.init(cgColor: color!),
        image: nil,
        previewImage: nil,
        isFavorite: shop.isFavorite,
        favoriteAddingDate: shop.favoriteAddingDate,
        promoCodes: promoCodes)
    }
    
//    /// Codable
//    private enum CodingKeys: String, CodingKey {
//        case name
//        case description
//        case shortDescription
//        case websiteLink
//        //case imageLink
//        //case previewImageLink
//        case placeholderColor
//        case image
//        case previewImage
//        case isFavorite
//        case favoriteAddingDate
//        case promocodes
//    }
    
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        name = try container.decode(String.self, forKey: .name)
//        description = try container.decode(String?.self, forKey: .description)
//        shortDescription = try container.decode(String.self, forKey: .shortDescription)
//        isHot
//        websiteLink = try container.decode(String.self, forKey: .websiteLink)
//        //imageLink = try container.decode(String.self, forKey: .imageLink)
//        //previewImageLink = try container.decode(String.self, forKey: .previewImageLink)
//        placeholderColor = try container.decode(UIColor.self, forKey: .placeholderColor)
//        _image = try container.decode(UIImage?.self, forKey: .image)
//        _previewImage = try container.decode(UIImage?.self, forKey: .previewImage)
//        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
//        favoriteAddingDate = try container.decode(Date?.self, forKey: .favoriteAddingDate)
//        promoCodes = try container.decode([PromoCodeData].self, forKey: .promocodes)
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(name, forKey: .name)
//        try container.encode(description, forKey: .description)
//        try container.encode(shortDescription, forKey: .shortDescription)
//        try container.encode(websiteLink, forKey: .websiteLink)
//        //try container.encode(imageLink, forKey: .imageLink)
//        //try container.encode(previewImageLink, forKey: .previewImageLink)
//        try container.encode(placeholderColor, forKey: .placeholderColor)
//        try container.encode(image, forKey: .image)
//        try container.encode(previewImage, forKey: .previewImage)
//        try container.encode(isFavorite, forKey: .isFavorite)
//        try container.encode(favoriteAddingDate, forKey: .favoriteAddingDate)
//        try container.encode(promoCodes, forKey: .promocodes)
//    }
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

//    // MARK: - Codable
//extension KeyedEncodingContainer {
//
//    mutating func encode(_ value: UIImage?,
//                         forKey key: KeyedEncodingContainer.Key) throws {
//        let imageData = value?.pngData()
//        try encode(imageData, forKey: key)
//    }
//    
//    mutating func encode(_ value: UIColor,
//                         forKey key: KeyedEncodingContainer.Key) throws {
//        let colorComponents = value.cgColor.components
//        try encode(colorComponents, forKey: key)
//    }
//
//}
//
//extension KeyedDecodingContainer {
//
//    public func decode(_ type: UIImage?.Type,
//                       forKey key: KeyedDecodingContainer.Key) throws -> UIImage? {
//        let imageData = try decode(Data?.self, forKey: key)
//        if  let data = imageData,
//            let image = UIImage(data: data) {
//            return image
//        } else {
//            return nil
//        }
//    }
//    
//    public func decode(_ type: UIColor.Type,
//                       forKey key: KeyedDecodingContainer.Key) throws -> UIColor {
//        let colorComponents = try decode([CGFloat]?.self, forKey: key)
//        if let components = colorComponents {
//            return UIColor.init(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: components)!)
//        } else {
//            return UIColor.black
//        }
//    }
//
//}
