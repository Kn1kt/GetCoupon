//
//  ShopCategoryData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 09.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ShopCategoryData {
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  
  let categoryName: String
  
  let priority: Int
  
  let tags: Set<String>
  
  var shops: [ShopData]
  
  let identifier = UUID()
  
  let defaultImageLink: String
  let defaultImage = BehaviorRelay<UIImage?>(value: nil)
  
  init(categoryName: String,
       priority: Int = 0,
       defaultImageLink: String = "",
       shops: [ShopData] = [],
       tags: Set<String> = []) {
    self.categoryName = categoryName
    self.priority = priority
    self.defaultImageLink = defaultImageLink
    self.shops = shops
    self.tags = tags
  }
  
  /// Bridge for stored data
  convenience init(_ category: ShopCategoryStoredData) {
    let tags = Set(category.tags)
    self.init(categoryName: category.categoryName,
              priority: category.priority,
              defaultImageLink: category.defaultImageLink,
              tags: tags)
    
    let shops = Array(category.shops).map { ShopData($0, category: self) }
    self.shops = shops
  }
}

  // MARK: - Hashable
extension ShopCategoryData: Hashable {
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  static func == (lhs: ShopCategoryData, rhs: ShopCategoryData) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}
