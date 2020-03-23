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
