//
//  CacheController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 11.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import Foundation
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
    
    func removeAll(shops: [ShopData]) {
        shops.forEach { shop in
            guard let storedShop = realm.object(ofType: ShopStoredData.self,
                                                forPrimaryKey: shop.name) else {
                debugPrint("No Shop")
                fatalError()
            }
            
            removeAllPromoCodes(from: storedShop)
            do {
                try realm.write {
                    realm.delete(storedShop)
                }
            } catch {
                debugPrint("Unexpected Error: \(error)")
            }
        }
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
    
    func removeAllPromoCodes(from shop: ShopData) {
        guard let storedShop = realm.object(ofType: ShopStoredData.self,
                                            forPrimaryKey: shop.name) else {
            debugPrint("No Shop")
            fatalError()
        }
        
        do {
            try realm.write {
                storedShop.promoCodes.forEach { promoCode in
                    realm.delete(promoCode)
                }
                storedShop.promoCodes.removeAll()
            }
        } catch {
            debugPrint("Unexpected Error: \(error)")
        }
    }
    
    // MARK: - Update Categories
    func update(category: ShopCategoryStoredData, with shops: [ShopStoredData]) {
        let exist = Set<ShopStoredData>(category.shops)
        let noExist = shops.filter { !exist.contains($0) }
        
        do {
            try realm.write {
                realm.add(shops, update: .modified)
                category.shops.append(objectsIn: noExist)
            }
        } catch {
            debugPrint("Unexpected Error: \(error)")
        }
    }
    
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
}
