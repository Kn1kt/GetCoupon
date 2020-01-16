//
//  Model.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 25.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import Network

class ModelController {

    static fileprivate var _collections: [ShopCategoryData] = []
    static private let collectionsQueue = DispatchQueue(label: "collectionsQueue", attributes: .concurrent)
    
     /// Main Collections
    static var collections: [ShopCategoryData] {
        get {
            collectionsQueue.sync {
                return _collections
            }
        }
        
        set {
            collectionsQueue.async(flags: .barrier) {
                self._collections = newValue
                NotificationCenter.default.post(name: .didUpdateCollections, object: nil)
            }
        }
    }
    
    /// Home Collections
    static var homeDataController: HomeDataController = createHomeDataController()
    
    /// Favorites Collections
    static var favoritesDataController: FavoritesDataController = createFavoritesDataController()
    
    static private var _favoritesCollections: [ShopCategoryData] = []
    
    static private let favoritesCollectionsQueue = DispatchQueue(label: "favoritesCollectionsQueue", attributes: .concurrent)
    static private var favoritesCollections: [ShopCategoryData] {
        get {
            favoritesCollectionsQueue.sync {
                return _favoritesCollections
            }
        }
        
        set {
            favoritesCollectionsQueue.async(flags: .barrier) {
                self._favoritesCollections = newValue
                self.favoritesDataController.collectionsBySections = newValue
            }
        }
    }
    
    /// Search Collection
    static var _searchCollection: ShopCategoryData = ShopCategoryData(categoryName: "Empty")
    static private let searchCollectionQueue = DispatchQueue(label: "searchCollectionQueue", attributes: .concurrent)
    static var searchCollection: ShopCategoryData {
        get {
            searchCollectionQueue.sync {
                return _searchCollection
            }
        }
        
        set {
            searchCollectionQueue.async(flags: .barrier) {
                self._searchCollection = newValue
                NotificationCenter.default.post(name: .didUpdateSearchCollections, object: nil)
            }
        }
    }
}

    // MARK: - Data Management
extension ModelController {
    
    static func setupCollections() {
        NetworkController.downloadDataBase()
    }
    
    static func loadCollectionsFromStorage() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let cache = CacheController()
            let categories = cache.categories()
            var favoriteCollections = [ShopCategoryData]()
            let collections = categories.reduce(into: [ShopCategoryData]()) { result, storedCategory in
                let category = ShopCategoryData(categoryName: storedCategory.categoryName,
                                                tags: Array(storedCategory.tags))
                let shops = Array(storedCategory.shops).reduce(into: [ShopData]()) { result, storedShop in
                    let shop = ShopData(storedShop)
                    if shop.isFavorite {
                        insert(in: &favoriteCollections, shop: shop, categoryName: category.categoryName)
                    }
                    result.append(shop)
                }
                category.shops = shops
                result.append(category)
            }
            
            self.collections = collections
            self.favoritesCollections = favoriteCollections
            
            setupSearchData()
            
            debugPrint("loaded Collections from storage")
        }
    }
    
    static private func insert(in collection: inout [ShopCategoryData], shop: ShopData, categoryName: String) {
        
        if let sectionIndex = collection.firstIndex(where: { $0.categoryName == categoryName }) {
            collection[sectionIndex].shops.append(shop)
        } else {
            collection.append(ShopCategoryData(categoryName: categoryName, shops: [shop]))
            collection.sort { $0.categoryName < $1.categoryName }
        }
    }
    
    static func removeCollectionsFromStorage() {
        let cache = CacheController()
        try! cache.realm.write {
            cache.realm.deleteAll()
        }
        debugPrint("deleted from storage")
    }
    
    
    static func section(for index: Int) -> ShopCategoryData? {
        guard index >= 0, collections.count > index else { return nil }
        
        return collections[index]
    }
}

    // MARK: - Home Section Data Controller
extension ModelController {
    
    static private func createHomeDataController() -> HomeDataController {
        let controller = HomeDataController()
        
        return controller
    }
}

    // MARK: - Favorites Section Data Controller
extension ModelController {
    
    static func updateFavoritesCollections(with collections: [ShopCategoryData]) {
        
        favoritesCollections = collections
        NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
    }
    
    static func insertInFavorites(shop: ShopData) {
        
        let section = collections.first { section in
            if section.shops.contains(shop) {
                return true
            }
            return false
        }
        
        if let sectionIndex = favoritesCollections.firstIndex(where: { $0.categoryName == section!.categoryName }) {
            favoritesCollections[sectionIndex].shops.append(shop)
        } else {
            favoritesCollections.append(ShopCategoryData(categoryName: section!.categoryName, shops: [shop]))
            favoritesCollections.sort { $0.categoryName < $1.categoryName }
        }
        
        NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
        favoritesDataController.collectionsBySections = favoritesCollections
    }
    
    static func deleteFromFavorites(shop: ShopData) {
        
        let section = collections.first { section in
            if section.shops.contains(shop) {
                return true
            }
            return false
        }
        
        if let sectionIndex = favoritesCollections.firstIndex(where: { $0.categoryName == section!.categoryName }) {
            if let removeIndex = favoritesCollections[sectionIndex].shops.firstIndex(where: { $0.identifier == shop.identifier }) {
                favoritesCollections[sectionIndex].shops.remove(at: removeIndex)
            }
            
            if favoritesCollections[sectionIndex].shops.isEmpty {
                favoritesCollections.remove(at: sectionIndex)
                favoritesCollections.sort { $0.categoryName < $1.categoryName }
            }
        }
        
        NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
        favoritesDataController.collectionsBySections = favoritesCollections
    }
    
    static func updateFavoritesCollections(in name: String,
                                           added addedCells: Set<ShopData>,
                                           deleted deletedCells: Set<ShopData>) {
        if let sectionIndex = favoritesCollections.firstIndex(where: { $0.categoryName == name }) {
            let section = favoritesCollections[sectionIndex]
            
            var reduced = section.shops.filter { shop in
                if addedCells.contains(shop) ||
                    deletedCells.contains(shop){
                    return false
                }
                return true
            }
            
            reduced.append(contentsOf: addedCells)
            
            if reduced.isEmpty {
                favoritesCollections.remove(at: sectionIndex)
                
            } else {
                section.shops = reduced
            }
            
        } else {
            if !addedCells.isEmpty {
                favoritesCollections.append(ShopCategoryData(categoryName: name, shops: Array(addedCells)))
            }
        }
        
        favoritesCollections.sort { $0.categoryName < $1.categoryName }
        favoritesDataController.collectionsBySections = favoritesCollections
    }
    
    static func removeAllFavorites() {
        
        guard !favoritesCollections.isEmpty else {
            return
        }
        
        favoritesCollections.forEach { section in
            let cache = CacheController()
            section.shops.forEach { shop in
                shop.isFavorite = false
                cache.shop(with: shop.name, isFavorite: false)
            }
        }
        favoritesCollections = []
        NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
    }
    
    static private func createFavoritesDataController() -> FavoritesDataController {
        let controller = FavoritesDataController(collections: favoritesCollections)
        
        return controller
    }
}

    // MARK: - Search Data
extension ModelController {
    
    static private func setupSearchData() {
        DispatchQueue.global(qos: .utility).async {
            let shops = collections.reduce(into: [ShopData]()) { result, section in
                result.append(contentsOf: section.shops)
            }
            
            let newCategory = ShopCategoryData(categoryName: "Search", shops: shops)
            searchCollection = newCategory
        }
    }
}
