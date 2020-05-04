//
//  CacheController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 11.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift

class CacheController {
  
  var realm: Realm! = nil
  
  init() {
    do {
      self.realm = try Realm()
    } catch {
      debugPrint("Some error \(error) in CacheController.init()")
    }
  }
  
  // MARK: - Add Categories
  func append(categories: [ShopCategoryStoredData]) {
    do {
      try realm.write {
        realm.add(categories)
      }
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
  
  func append(category: ShopCategoryStoredData) {
    do {
      try realm.write {
        realm.add(category)
      }
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
  
  // MARK: - Add Shops
  func append(shops: [ShopStoredData], in category: ShopCategoryStoredData) {
    do {
      try realm.write {
        realm.add(shops)
        category.shops.append(objectsIn: shops)
      }
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
  
  func append(shop: ShopStoredData, in category: ShopCategoryStoredData) {
    do {
      try realm.write {
        realm.add(shop)
        category.shops.append(shop)
      }
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
  
  // MARK: - Add Promo Codes
  func append(promoCodes: [PromoCodeStoredData], in shop: ShopStoredData) {
    do {
      try realm.write {
        realm.add(promoCodes)
        shop.promoCodes.append(objectsIn: promoCodes)
      }
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
  
  // MARK: - Remove Categories
  func removeAll(categories: [ShopCategoryData]) {
    categories.forEach { category in
      guard let storedCategory = realm.object(ofType: ShopCategoryStoredData.self,
                                              forPrimaryKey: category.categoryName) else {
        debugPrint("No Category")
//        fatalError()
        return
      }
      
      removeAll(shops: storedCategory.shops)
      do {
        try realm.write {
          realm.delete(storedCategory)
        }
      } catch {
        debugPrint("Unexpected Error: \(error)")
      }
    }
  }
  
  // MARK: - Remove Shops
  private func removeAll(shops: List<ShopStoredData>) {
    shops.forEach { shop in
      removeAllPromoCodes(from: shop)
      do {
        try realm.write {
          realm.delete(shop)
        }
      } catch {
        debugPrint("Unexpected Error: \(error)")
      }
    }
  }
  
  // MARK: - Remove All Files
  func removeCollectionsFromStorage() {
    do {
      clearImageCache()
      try realm.write {
        realm.deleteAll()
      }
    } catch {
      debugPrint(error.localizedDescription)
    }
    
    debugPrint("Deleted From Storage")
  }
  
  // MARK: - Remove Promocodes
  private func removeAllPromoCodes(from shop: ShopStoredData) {
    do {
      try realm.write {
        shop.promoCodes.forEach { promoCode in
          realm.delete(promoCode)
        }
        shop.promoCodes.removeAll()
      }
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
  
  // MARK: - Access Through Primary Key
  /// Category for primary key
  func category(with categoryName: String) -> ShopCategoryStoredData? {
    let category = realm.object(ofType: ShopCategoryStoredData.self,
                                forPrimaryKey: categoryName)
    return category
  }
  
  /// Category for primary key as Observable
  func category(with categoryName: String) -> Observable<ShopCategoryStoredData?> {
    let category = realm.object(ofType: ShopCategoryStoredData.self,
                                forPrimaryKey: categoryName)
    return Observable.just(category)
  }
  
  /// Shop for primary key
  func shop(with name: String) -> ShopStoredData? {
    let shop = realm.object(ofType: ShopStoredData.self,
                            forPrimaryKey: name)
    return shop
  }
  
  /// Shop for primary key as Observable
  func shop(with name: String) -> Observable<ShopStoredData?> {
    let shop = realm.object(ofType: ShopStoredData.self,
                            forPrimaryKey: name)
    return Observable.just(shop)
  }
  
  /// All categories
  func categories() -> [ShopCategoryStoredData] {
    let categories = realm.objects(ShopCategoryStoredData.self)
    
    return Array(categories)
  }
  
  /// All categories as Observable
  func categories() -> Observable<[ShopCategoryStoredData]> {
    let categories = realm.objects(ShopCategoryStoredData.self)
    
    return Observable.just(Array(categories))
  }
  
  /// All shops
  func shops() -> [ShopStoredData] {
    let shops = realm.objects(ShopStoredData.self)
    
    return Array(shops)
  }
  
  /// All shops as Observable
  func shops() -> Observable<[ShopStoredData]> {
    let shops = realm.objects(ShopStoredData.self)
    
    return Observable.just(Array(shops))
  }
  
  // MARK: - Update Categories
  func updateData(with categories: [NetworkShopCategoryData]) {
    var invalidatedShops = [String : (Bool, Date?)]()
    var validatedCategories = Set<String>()
    
    do {
      try realm.write {
        categories.forEach { newCategory in
          update(category: newCategory,
                 invalidatedShops: &invalidatedShops,
                 validatedCategories: &validatedCategories)
        }
        
        checkValidity(validatedCategories)
      }
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
  
  /// WARNING: Use only from realm.write
  private func update(category: NetworkShopCategoryData,
                      invalidatedShops: inout [String : (Bool, Date?)],
                      validatedCategories: inout Set<String>) {
    
    if let storedCategory = realm.object(ofType: ShopCategoryStoredData.self, forPrimaryKey: category.categoryName) {
      
      if category.defaultImageLink != storedCategory.defaultImageLink {
        storedCategory.defaultImageLink = category.defaultImageLink
        storedCategory.defaultImageURL = nil
      }
      
      var existing = Set<String>()
      category.shops.forEach { shop in
        if let storedShop = realm.object(ofType: ShopStoredData.self, forPrimaryKey: shop.name) {
          update(storedShop: storedShop, with: shop, in: storedCategory)
        } else {
          let newStoredShop = ShopStoredData(shop, category: storedCategory)
          if let favoriteAttributes = invalidatedShops[newStoredShop.name] {
            newStoredShop.isFavorite = favoriteAttributes.0
            newStoredShop.favoriteAddingDate = favoriteAttributes.1
            invalidatedShops[newStoredShop.name] = nil
          }
          realm.add(newStoredShop)
          storedCategory.shops.append(newStoredShop)
        }
        existing.insert(shop.name)
      }
      
      // Clean Cache
      if existing.count != storedCategory.shops.count {
        storedCategory.shops.indices.reversed().forEach { index in
          let storedShop = storedCategory.shops[index]
          if !existing.contains(storedShop.name) {
            invalidatedShops[storedShop.name] = (storedShop.isFavorite, storedShop.favoriteAddingDate)
            
            storedShop.promoCodes.forEach { promoCode in
              realm.delete(promoCode)
            }
            deleteImages(from: storedShop)
            storedCategory.shops.remove(at: index)
            realm.delete(storedShop)
          }
        }
      }
      
      if storedCategory.shops.isEmpty {
        deleteDefaultImage(from: storedCategory)
        realm.delete(storedCategory)
      }
      
    } else if !category.shops.isEmpty {
      let newStoredCategory = ShopCategoryStoredData(category)
      realm.add(newStoredCategory)
    }
    
    validatedCategories.insert(category.categoryName)
  }
  
  /// WARNING: Use only from realm.write
  private func checkValidity(_ validated: Set<String>) {
    let categories: [ShopCategoryStoredData] = self.categories()
    if categories.count != validated.count {
      categories.forEach { category in
        if !validated.contains(category.categoryName) {
          category.shops.forEach { shop in
            shop.promoCodes.forEach { promoCode in
              realm.delete(promoCode)
            }
            deleteImages(from: shop)
            realm.delete(shop)
          }
          deleteDefaultImage(from: category)
          realm.delete(category)
        }
      }
    }
  }
  
  /// WARNING: Use only from realm.write
  private func update(storedShop: ShopStoredData, with shop: NetworkShopData, in category: ShopCategoryStoredData) {
    if storedShop.category != category {
      if let index = storedShop.category.shops.firstIndex(of: storedShop) {
        storedShop.category.shops.remove(at: index)
      }
      
      storedShop.category = category
      category.shops.append(storedShop)
    }
    
    if let newDescription = shop.shopDescription {
      if let oldDescription = storedShop.shopDescription {
        if newDescription != oldDescription {
          storedShop.shopDescription = newDescription
        }
      } else {
        storedShop.shopDescription = newDescription
      }
    }
    
    if shop.shopShortDescription != storedShop.shopShortDescription {
      storedShop.shopShortDescription = shop.shopShortDescription
    }
    
//    if shop.isHot != storedShop.isHot {
//      storedShop.isHot = shop.isHot
//    }
    if shop.priority != storedShop.priority {
      storedShop.priority = shop.priority
    }
    
    if shop.websiteLink != storedShop.websiteLink {
      storedShop.websiteLink = shop.websiteLink
    }
    
    if shop.previewImageLink != storedShop.previewImageLink {
      storedShop.previewImageLink = shop.previewImageLink
      //deletePreviewImage(from: storedShop)
      storedShop.previewImageURL = nil
    }
    
    if shop.imageLink != storedShop.imageLink {
      storedShop.imageLink = shop.imageLink
      //deleteImage(from: storedShop)
      storedShop.imageURL = nil
    }
    
    if shop.placeholderColor != Array(storedShop.placeholderColor) {
      storedShop.placeholderColor.replaceSubrange((0..<storedShop.placeholderColor.count), with: shop.placeholderColor)
    }
    
    updatePromoCodes(in: storedShop, with: shop)
  }
  
  /// WARNING: Use only from realm.write
  private func updatePromoCodes(in storedShop: ShopStoredData, with shop: NetworkShopData) {
    var promoCodes = shop.promoCodes.reduce(into: [String : NetworkPromoCodeData]()) { result, promo in
      result[promo.coupon] = promo
    }
    storedShop.promoCodes.indices.reversed().forEach { index in
      let storedPromoCode = storedShop.promoCodes[index]
      if let _ = promoCodes[storedPromoCode.coupon] {
        promoCodes.removeValue(forKey: storedPromoCode.coupon)
      } else {
        storedShop.promoCodes.remove(at: index)
        realm.delete(storedPromoCode)
      }
    }
    
    if !promoCodes.isEmpty {
      let newPromoCodes = promoCodes.values.map(PromoCodeStoredData.init)
      realm.add(newPromoCodes)
      storedShop.promoCodes.append(objectsIn: newPromoCodes)
    }
  }
  
  // MARK: - Update Favorites
  func shop(with name: String, isFavorite: Bool, date: Date?) {
    guard let shop = realm.object(ofType: ShopStoredData.self,
                                  forPrimaryKey: name) else {
      debugPrint("No Shop")
//      fatalError()
      return
    }
    do {
      try realm.write {
        shop.isFavorite = isFavorite
        shop.favoriteAddingDate = date
      }
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
}

  // MARK: - Images
extension CacheController {
  
  func setImage(for shop: ShopData) -> String? {
    guard shop.image == nil else { return nil }
    guard let storedShop = realm.object(ofType: ShopStoredData.self,
                                        forPrimaryKey: shop.name) else {
      debugPrint("No Shop")
//      fatalError()
      return nil
    }
    
    if let url = storedShop.imageURL,
      let image = UIImage(contentsOfFile: url) {
      if shop.image == nil {
        shop.image = image
      }
      return nil
      
    } else {
      return storedShop.imageLink
    }
  }
  
  func setPreviewImage(for shop: ShopData) -> String? {
    guard shop.previewImage == nil else { return nil }
    guard let storedShop = realm.object(ofType: ShopStoredData.self,
                                        forPrimaryKey: shop.name) else {
      debugPrint("No Shop")
//      fatalError()
      return nil
    }
    
    if let url = storedShop.previewImageURL,
      let image = UIImage(contentsOfFile: url) {
      if shop.previewImage == nil {
        shop.previewImage = image
      }
      return nil
      
    } else {
      return storedShop.previewImageLink
    }
  }
  
  func setDefaultImage(for category: ShopCategoryData) -> String? {
    guard category.defaultImage == nil else { return nil }
    guard let storedCategory = realm.object(ofType: ShopCategoryStoredData.self,
                                            forPrimaryKey: category.categoryName) else {
      debugPrint("No Category")
//      fatalError()
      return nil
    }
    
    if let url = storedCategory.defaultImageURL,
      let image = UIImage(contentsOfFile: url) {
      if category.defaultImage == nil {
        category.defaultImage = image
      }
      return nil
      
    } else {
      return storedCategory.defaultImageLink
    }
  }
  
  func cacheImage(_ image: UIImage, for shop: String) {
    let directoryURL = FileManager.default.urls(for: .cachesDirectory,
                                                in: .userDomainMask).first
    let fileURL = URL(fileURLWithPath: "\(shop)-image", relativeTo: directoryURL).appendingPathExtension("png")
    guard let storedShop = realm.object(ofType: ShopStoredData.self,
                                        forPrimaryKey: shop) else {
      debugPrint("No Shop")
//      fatalError()
      return
    }
    
    do {
      try image.pngData()?.write(to: fileURL, options: .noFileProtection)
      try realm.write {
        storedShop.imageURL = fileURL.path
      }
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
  
  func cachePreviewImage(_ image: UIImage, for shop: String) {
    let directoryURL = FileManager.default.urls(for: .cachesDirectory,
                                                in: .userDomainMask).first
    let fileURL = URL(fileURLWithPath: "\(shop)-previewImage", relativeTo: directoryURL).appendingPathExtension("png")
    guard let storedShop = realm.object(ofType: ShopStoredData.self,
                                        forPrimaryKey: shop) else {
      debugPrint("No Shop")
//      fatalError()
      return
    }
    
    do {
      try image.pngData()?.write(to: fileURL, options: .noFileProtection)
      try realm.write {
        storedShop.previewImageURL = fileURL.path
      }
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
  
  func cacheDefaultImage(_ image: UIImage, for category: String) {
    let directoryURL = FileManager.default.urls(for: .cachesDirectory,
                                                in: .userDomainMask).first
    let fileURL = URL(fileURLWithPath: "\(category)-defaultImage", relativeTo: directoryURL).appendingPathExtension("png")
    guard let storedCategory = realm.object(ofType: ShopCategoryStoredData.self,
                                        forPrimaryKey: category) else {
      debugPrint("No Category")
//      fatalError()
      return
    }
    
    do {
      try image.pngData()?.write(to: fileURL, options: .noFileProtection)
      try realm.write {
        storedCategory.defaultImageURL = fileURL.path
      }
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
  
  private func deleteImages(from shop: ShopStoredData) {
    
    do {
      if let previewPath = shop.previewImageURL {
        let url = URL(fileURLWithPath: previewPath)
        try FileManager.default.removeItem(at: url)
      }
      
      if let imagePath = shop.imageURL {
        let url = URL(fileURLWithPath: imagePath)
        try FileManager.default.removeItem(at: url)
      }
      debugPrint("Deleted Old Images From \(shop.name)")
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
  
  private func deletePreviewImage(from shop: ShopStoredData) {
    do {
      if let previewPath = shop.previewImageURL {
        let url = URL(fileURLWithPath: previewPath)
        try FileManager.default.removeItem(at: url)
      }
      debugPrint("Deleted Old Preview Image From \(shop.name)")
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
  
  private func deleteImage(from shop: ShopStoredData) {
    do {
      if let imagePath = shop.imageURL {
        let url = URL(fileURLWithPath: imagePath)
        try FileManager.default.removeItem(at: url)
      }
      debugPrint("Deleted Old Image From \(shop.name)")
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
  
  private func deleteDefaultImage(from category: ShopCategoryStoredData) {
    do {
      if let imagePath = category.defaultImageURL {
        let url = URL(fileURLWithPath: imagePath)
        try FileManager.default.removeItem(at: url)
      }
      debugPrint("Deleted Old Default Image From \(category.categoryName)")
    } catch {
      debugPrint("Unexpected Error: \(error)")
    }
  }
  
  func clearImageCache() {
    categories().forEach { category in
      deleteDefaultImage(from: category)
      category.shops.forEach(deleteImages(from:))
    }
  }
}
