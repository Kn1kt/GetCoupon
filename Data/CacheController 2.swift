//
//  CacheController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 11.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RealmSwift

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
                fatalError()
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
    
//    func removeAll(shops: [ShopData]) {
//        shops.forEach { shop in
//            guard let storedShop = realm.object(ofType: ShopStoredData.self,
//                                                forPrimaryKey: shop.name) else {
//                debugPrint("No Shop")
//                fatalError()
//            }
//
//            removeAllPromoCodes(from: storedShop)
//            do {
//                try realm.write {
//                    realm.delete(storedShop)
//                }
//            } catch {
//                debugPrint("Unexpected Error: \(error)")
//            }
//        }
//    }
    
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
    
//    func removeAllPromoCodes(from shop: ShopData) {
//        guard let storedShop = realm.object(ofType: ShopStoredData.self,
//                                            forPrimaryKey: shop.name) else {
//            debugPrint("No Shop")
//            fatalError()
//        }
//        
//        do {
//            try realm.write {
//                storedShop.promoCodes.forEach { promoCode in
//                    realm.delete(promoCode)
//                }
//                storedShop.promoCodes.removeAll()
//            }
//        } catch {
//            debugPrint("Unexpected Error: \(error)")
//        }
//    }
    
    // MARK: - Access Through Primary Key
    func category(with categoryName: String) -> ShopCategoryStoredData? {
        let category = realm.object(ofType: ShopCategoryStoredData.self,
                                    forPrimaryKey: categoryName)
        return category
    }
    
    func shop(with name: String) -> ShopStoredData? {
        let shop = realm.object(ofType: ShopStoredData.self,
                                forPrimaryKey: name)
        return shop
    }
    
    func categories() -> [ShopCategoryStoredData] {
        let categories = realm.objects(ShopCategoryStoredData.self)
        
        return Array(categories)
    }
    
    func shops() -> [ShopStoredData] {
        let shops = realm.objects(ShopStoredData.self)
        
        return Array(shops)
    }
    
    // MARK: - Update Categories
    func updateData(with categories: [NetworkShopCategoryData]) {
        do {
            try realm.write {
                categories.forEach { newCategory in
                    update(category: newCategory)
                }
            }
        } catch {
            debugPrint("Unexpected Error: \(error)")
        }
    }
    
    /// WARNING: Use only from realm.write
    private func update(category: NetworkShopCategoryData) {
        if let storedCategory = realm.object(ofType: ShopCategoryStoredData.self, forPrimaryKey: category.categoryName) {
            var existing = Set<String>()
            category.shops.forEach { shop in
                if let storedShop = realm.object(ofType: ShopStoredData.self, forPrimaryKey: shop.name) {
                    update(storedShop: storedShop, with: shop)
                } else {
                    let newStoredShop = ShopStoredData(shop)
                    realm.add(newStoredShop)
                    storedCategory.shops.append(newStoredShop)
                }
                existing.insert(shop.name)
            }
            
            // Clean Cache
            storedCategory.shops.indices.reversed().forEach { index in
                let storedShop = storedCategory.shops[index]
                if !existing.contains(storedShop.name) {
                    storedShop.promoCodes.forEach { promoCode in
                        realm.delete(promoCode)
                    }
                    deleteImages(from: storedShop)
                    realm.delete(storedShop)
                }
            }
            
        } else {
            let newStoredCategory = ShopCategoryStoredData(category)
            realm.add(newStoredCategory)
        }
    }
    
    /// WARNING: Use only from realm.write
    private func update(storedShop: ShopStoredData, with shop: NetworkShopData) {
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
        
        if shop.isHot != storedShop.isHot {
            storedShop.isHot = shop.isHot
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
    
    // MARK: - Update Favorite
    func shop(with name: String, isFavorite: Bool, date: Date? = nil) {
        guard let shop = realm.object(ofType: ShopStoredData.self,
                                      forPrimaryKey: name) else {
            debugPrint("No Shop")
            fatalError()
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
            fatalError()
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
            fatalError()
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
    
    func cacheImage(_ image: UIImage, for shop: String) {
        let directoryURL = FileManager.default.urls(for: .cachesDirectory,
            in: .userDomainMask).first
        let fileURL = URL(fileURLWithPath: "\(shop)-image", relativeTo: directoryURL).appendingPathExtension("png")
        guard let storedShop = realm.object(ofType: ShopStoredData.self,
                                            forPrimaryKey: shop) else {
            debugPrint("No Shop")
            fatalError()
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
            fatalError()
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
}
