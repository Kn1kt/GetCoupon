//
//  ShopData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 06.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ShopData {
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  
  let name: String
  let description: String?
  let shortDescription: String
  
  let priority: Int
  
  var websiteLink: String
  
  var imageLink: String
  let image = BehaviorRelay<UIImage?>(value: nil)
  
  let previewImageLink: String
  let previewImage = BehaviorRelay<UIImage?>(value: nil)
  
  let placeholderColor: UIColor
  
  var isFavorite: Bool
  var favoriteAddingDate: Date?
  
  var promoCodes: [PromoCodeData]
  
  weak var category: ShopCategoryData?
  let identifier = UUID()
  
  init(name: String,
       description: String? = nil,
       shortDescription: String,
       priority: Int = 0,
       websiteLink: String,
       placeholderColor: UIColor = .systemGray3,
       imageLink: String = "",
       previewImageLink: String = "",
       isFavorite: Bool = false,
       favoriteAddingDate: Date? = nil,
       promoCodes: [PromoCodeData] = [],
       category: ShopCategoryData = ShopCategoryData(categoryName: "STUB")) {
    self.name = name
    self.description = description
    self.shortDescription = shortDescription
    self.priority = priority
    self.websiteLink = websiteLink
    self.placeholderColor = placeholderColor
    self.imageLink = imageLink
    self.previewImageLink = previewImageLink
    self.promoCodes = promoCodes
    self.isFavorite = isFavorite
    self.favoriteAddingDate = favoriteAddingDate
    self.category = category
  }
  
  convenience init(name: String, shortDescription: String) {
    self.init(name: name,
              description: nil,
              shortDescription: shortDescription,
              websiteLink: "",
              isFavorite: false,
              promoCodes: [],
              category: ShopCategoryData(categoryName: "STUB"))
  }
  
  /// Bridge for stored data
  convenience init(_ shop: ShopStoredData, category: ShopCategoryData) {
    let color = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(),
                        components: Array(shop.placeholderColor).map(CGFloat.init))
    let promoCodes = Array(shop.promoCodes).map(PromoCodeData.init)
    
    self.init(name: shop.name,
              description: shop.shopDescription,
              shortDescription: shop.shopShortDescription,
              priority: shop.priority,
              websiteLink: shop.websiteLink,
              placeholderColor: UIColor.init(cgColor: color!),
              imageLink: shop.imageLink,
              previewImageLink: shop.previewImageLink,
              isFavorite: shop.isFavorite,
              favoriteAddingDate: shop.favoriteAddingDate,
              promoCodes: promoCodes,
              category: category)
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
