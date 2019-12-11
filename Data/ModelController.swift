//
//  Model.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 25.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ModelController {
    
    /// Main Collection
    static fileprivate var _collections: [ShopCategoryData] = []
    static private let collectionsQueue = DispatchQueue(label: "collectionsQueue", attributes: .concurrent)
    static var collections: [ShopCategoryData] {
        get {
            collectionsQueue.sync {
                return _collections
            }
        }
        
        set {
            collectionsQueue.async(flags: .barrier) {
                self._collections = newValue
            }
            NotificationCenter.default.post(name: .didUpdateCollections, object: nil)
            updateFavoritesCollections()
        }
    }
    
    /// Home Collections
    static private var _homeDataController: HomeDataController?
    
    static var homeDataController: HomeDataController {
        
        if _homeDataController == nil {
            _homeDataController = createHomeDataController()
        }
        
        return _homeDataController!
    }
    
//    static private var _homeCollections: [ShopCategoryData]?
//
//    static var homeCollections: [ShopCategoryData] {
//        get {
//            if _homeCollections == nil {
//                updateHomeCollections()
//            }
//
//            return _homeCollections!
//        }
//    }
    
    /// Favorites Collection
    static private var _favoritesDataController: FavoritesDataController?
    
    static var favoritesDataController: FavoritesDataController {
        
        if _favoritesDataController == nil {
            _favoritesDataController = createFavoritesDataController()
        }
        
        return _favoritesDataController!
    }
    
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
            }
        }
    }
    
    /// Search Collection
    static private var _searchCollection: ShopCategoryData?
    
    static var searchCollection: ShopCategoryData {
        get {
            if _searchCollection == nil {
                _searchCollection = setupSearchData()
            }
            
            return _searchCollection!
        }
    }
    
    
}

    // MARK: - Data Management

extension ModelController {
    
    static func updateCollections() {
        
        // There gonna be some database query methods
        
        generateCollections()
    }
    
    static func loadCollectionsToStorage() {
        
        //DispatchQueue.global(qos: .background).async {
            
            let directoryURL = FileManager.default.urls(for: .cachesDirectory,
                in: .userDomainMask).first
            let fileURL = URL(fileURLWithPath: "collections", relativeTo: directoryURL).appendingPathExtension("json")
            do {
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(collections)
                try jsonData.write(to: fileURL, options: .noFileProtection)
            } catch {
                debugPrint(error)
            }
            
            debugPrint("loaded to storage")
        //}
    }
    
    static func loadCollectionFromStorage() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let directoryURL = FileManager.default.urls(for: .cachesDirectory,
                in: .userDomainMask).first
            let fileURL = URL(fileURLWithPath: "collections", relativeTo: directoryURL).appendingPathExtension("json")
            do {
                
                let jsonDecoder = JSONDecoder()
                let jsonData = try Data(contentsOf: fileURL)
                let decodedCollections = try jsonDecoder.decode([ShopCategoryData].self, from: jsonData)
                collections = decodedCollections
            } catch {
                debugPrint(error)
                generateCollections()
            }
            
            debugPrint("loaded from storage")
        }
    }
    
    
    static func section(for index: Int) -> ShopCategoryData? {
        guard index >= 0, collections.count > index else { return nil }
        
        return collections[index]
    }
    
    /// FOR TESTS
    static func generateCollections() {
        let promocodes = [
                PromocodeData(coupon: "COUPON30",
                              addingDate: Date(timeIntervalSinceNow: -1000),
                              estimatedDate: Date(timeIntervalSinceNow: 1000),
                              description: "save ur 30%",
                              isHot: false),
                PromocodeData(coupon: "COUPON20",
                              addingDate: Date(timeIntervalSinceNow: -2000),
                              estimatedDate: Date(timeIntervalSinceNow: 2000),
                              description: "save ur 20%",
                              isHot: false),
                PromocodeData(coupon: "COUPON10",
                              addingDate: Date(timeIntervalSinceNow: -3000),
                              estimatedDate: Date(timeIntervalSinceNow: 3000),
                              description: "save your 10% when spent more than 1000",
                              isHot: false),
                PromocodeData(coupon: "COUPON30",
                              addingDate: Date(timeIntervalSinceNow: -1000),
                              estimatedDate: Date(timeIntervalSinceNow: 1000),
                              description: "save ur 30%",
                              isHot: false),
                PromocodeData(coupon: "COUPON20",
                              addingDate: Date(timeIntervalSinceNow: -2000),
                              estimatedDate: Date(timeIntervalSinceNow: 2000),
                              description: "save ur 20%",
                              isHot: false),
                PromocodeData(coupon: "COUPON10",
                              addingDate: Date(timeIntervalSinceNow: -3000),
                              estimatedDate: Date(timeIntervalSinceNow: 3000),
                              description: "save your 10% when spent more than 1000",
                              isHot: false),
                PromocodeData(coupon: "COUPON30",
                              addingDate: Date(timeIntervalSinceNow: -1000),
                              estimatedDate: Date(timeIntervalSinceNow: 1000),
                              description: "save ur 30%",
                              isHot: false),
                PromocodeData(coupon: "COUPON20",
                              addingDate: Date(timeIntervalSinceNow: -2000),
                              estimatedDate: Date(timeIntervalSinceNow: 2000),
                              description: "save ur 20%",
                              isHot: false),
                PromocodeData(coupon: "COUPON10",
                              addingDate: Date(timeIntervalSinceNow: -3000),
                              estimatedDate: Date(timeIntervalSinceNow: 3000),
                              description: "save your 10% when spent more than 1000",
                              isHot: false)
        ]
        collections = [
            ShopCategoryData(categoryName: "HOT 🔥",
                            shops: [ShopData(image: UIImage(named: "Delivery"),
                                             name: "Delivery Club",
                                             shortDescription: "Save your 35%"),
                                    ShopData(image: UIImage(named: "Yandex"),
                                             name: "Yandex Food",
                                             shortDescription: "Save your 15%"),
                                    ShopData(image: UIImage(named: "WaterPark"),
                                             name: "Water Park Caribbean",
                                             shortDescription: "Your have personal coupon"),
                                    ShopData(image: UIImage(named: "Ozon"),
                                             name: "Ozon",
                                             shortDescription: "Save your 25%"),
                                    ShopData(image: UIImage(named: "AliExpress"),
                                             name: "AliExpress",
                                             shortDescription: "Save your 60%"),
                                    ShopData(image: UIImage(named: "ASOS"),
                                             name: "ASOS",
                                             shortDescription: "Your have personal coupon"),
                                    ShopData(image: UIImage(named: "Amazon"),
                                             name: "Amazon",
                                             shortDescription: "Save your 30%"),
                                    ShopData(image: UIImage(named: "Apple"),
                                             name: "Apple",
                                             shortDescription: "Special inventational")]),
            ShopCategoryData(categoryName: "Food",
                            shops: [ShopData(image: UIImage(named: "KFC"),
                                             name: "KFC",
                                             shortDescription: "Two for one price"),
                                    ShopData(image: UIImage(named: "McDonald's"),
                                             name: "McDonald's",
                                             shortDescription: "New menu"),
                                    ShopData(image: UIImage(named: "Yakitoria"),
                                             name: "Yakitoria",
                                             shortDescription: "Save your 10%"),
                                    ShopData(image: UIImage(named: "KFC"),
                                             name: "KFC",
                                             shortDescription: "Two for one price"),
                                    ShopData(image: UIImage(named: "McDonald's"),
                                             name: "McDonald's",
                                             shortDescription: "New menu"),
                                    ShopData(image: UIImage(named: "McDonald's"),
                                             name: "McDonald's",
                                             shortDescription: "New menu"),
                                    ShopData(image: UIImage(named: "Yakitoria"),
                                             name: "Yakitoria",
                                             shortDescription: "Save your 10%"),
                                    ShopData(image: UIImage(named: "KFC"),
                                             name: "KFC",
                                             shortDescription: "Two for one price"),
                                    ShopData(image: UIImage(named: "McDonald's"),
                                             name: "McDonald's",
                                             shortDescription: "New menu"),
                                    ShopData(image: UIImage(named: "McDonald's"),
                                             name: "McDonald's",
                                             shortDescription: "New menu"),
                                    ShopData(image: UIImage(named: "Yakitoria"),
                                             name: "Yakitoria",
                                             shortDescription: "Save your 10%"),
                                    ShopData(image: UIImage(named: "KFC"),
                                             name: "KFC",
                                             shortDescription: "Two for one price"),
                                    ShopData(image: UIImage(named: "McDonald's"),
                                             name: "McDonald's",
                                             shortDescription: "New menu"),
                                    ShopData(image: UIImage(named: "Yakitoria"),
                                             name: "Yakitoria",
                                             shortDescription: "Save your 10%")]),
            ShopCategoryData(categoryName: "Other",
                             shops: [ShopData(image: UIImage(named: "Amazon"),
                                             name: "Amazon",
                                             shortDescription: "Save your 30%"),
                                     ShopData(image: UIImage(named: "Apple"),
                                             name: "Apple",
                                             shortDescription: "Special inventational"),
                                     ShopData(image: UIImage(named: "AliExpress"),
                                             name: "AliExpress",
                                             shortDescription: "Save your 60%"),
                                     ShopData(image: UIImage(named: "ASOS"),
                                             name: "ASOS",
                                             shortDescription: "Your have personal coupon")])
        ]
        collections.forEach { category in
            category.shops.forEach { shop in
                shop.promocodes.append(contentsOf: promocodes)
            }
        }
    }
}

    // MARK: - Home Section Data Controller
extension ModelController {
    
    static private func createHomeDataController() -> HomeDataController {
        
        let controller = HomeDataController()
        
        return controller
    }
    
//    static private func updateHomeCollections() {
//
//        _homeCollections = collections.reduce(into: [ShopCategoryData]()){ result, section in
//
//            let shops = Array(section.shops.prefix(15))
//
//            let reducedSection = ShopCategoryData(categoryName: section.categoryName,
//                                             shops: shops)
//
//            result.append(reducedSection)
//        }
//    }
    
}

    // MARK: - Favorites Section Data Controller

extension ModelController {
    
    static private func updateFavoritesCollections() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let favoritesCollections = collections.reduce(into: [ShopCategoryData]()) { result, section in
                let shops = section.shops.filter { $0.isFavorite }
                if !shops.isEmpty {
                    let newSection = ShopCategoryData(categoryName: section.categoryName, shops: shops, tags: [])
                    result.append(newSection)
                }
            }.sorted { $0.categoryName < $1.categoryName }
            //NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
            self.favoritesCollections = favoritesCollections
            favoritesDataController.collectionsBySections = favoritesCollections
        }
    }
    
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
    
    static func updateFavoritesCollections(in name: String, with addedCells: Set<ShopData> = []) {
            
        if let sectionIndex = favoritesCollections.firstIndex(where: { $0.categoryName == name }) {
            let section = favoritesCollections[sectionIndex]
            
            var reduced = section.shops.filter { cell in
                if addedCells.contains(cell) {
                    return false
                }
                
                return cell.isFavorite
            }
            
            reduced.append(contentsOf: addedCells)
            
            if reduced.isEmpty {
                favoritesCollections.remove(at: sectionIndex)
            } else {
                section.shops = reduced
            }
            
        } else {
            favoritesCollections.append(ShopCategoryData(categoryName: name, shops: Array(addedCells)))
        }
        
        favoritesCollections.sort { $0.categoryName < $1.categoryName }
        favoritesDataController.collectionsBySections = favoritesCollections

        
    }
    
    static func removeAllFavorites() {
        
        guard !favoritesCollections.isEmpty else {
            return
        }
        
        favoritesCollections.forEach { section in
            section.shops.forEach { cell in
                cell.isFavorite = false
            }
        }
        favoritesCollections = []
        favoritesDataController.collectionsBySections = []
        NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
    }
    
    static private func createFavoritesDataController() -> FavoritesDataController {
        
        let controller = FavoritesDataController(collections: favoritesCollections)
        
        return controller
    }
}

    // MARK: - Search Data

extension ModelController {
    
    static private func setupSearchData() -> ShopCategoryData {
        
        let shops = collections.reduce(into: [ShopData]()) { result, section in
            result.append(contentsOf: section.shops)
        }
        
        return ShopCategoryData(categoryName: "Search", shops: shops)
    }
}
