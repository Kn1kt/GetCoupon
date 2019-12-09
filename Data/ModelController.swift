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
    static fileprivate var _collections: [ShopCategoryData]?
    
    static var collections: [ShopCategoryData] {
        get {
            if _collections == nil {
                updateCollections()
            }
            return _collections!
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
    
    static private var _homeCollections: [ShopCategoryData]?
    
    static var homeCollections: [ShopCategoryData] {
        get {
            if _homeCollections == nil {
                updateHomeCollections()
            }
            
            return _homeCollections!
        }
    }
    
    /// Favorites Collection
    static private var _favoritesDataController: FavoritesDataController?
    
    static var favoritesDataController: FavoritesDataController {
        
        if _favoritesDataController == nil {
            _favoritesDataController = createFavoritesDataController()
        }
        
        return _favoritesDataController!
    }
    
    static private var favoritesCollections: [ShopCategoryData] = []
    
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
    
    static func section(for index: Int) -> ShopCategoryData? {
        guard index >= 0, collections.count > index else { return nil }
        
        return collections[index]
    }
    
    
    /// FOR TESTS
    static func generateCollections() {
        let promocodes = [
                PromocodeData(name: "COUPON30",
                              addingDate: Date(timeIntervalSinceNow: -1000),
                              estimatedDate: Date(timeIntervalSinceNow: 1000),
                              description: "save ur 30%",
                              isHot: false),
                PromocodeData(name: "COUPON20",
                              addingDate: Date(timeIntervalSinceNow: -2000),
                              estimatedDate: Date(timeIntervalSinceNow: 2000),
                              description: "save ur 20%",
                              isHot: false),
                PromocodeData(name: "COUPON10",
                              addingDate: Date(timeIntervalSinceNow: -3000),
                              estimatedDate: Date(timeIntervalSinceNow: 3000),
                              description: "save your 10% when spent more than 1000",
                              isHot: false),
                PromocodeData(name: "COUPON30",
                              addingDate: Date(timeIntervalSinceNow: -1000),
                              estimatedDate: Date(timeIntervalSinceNow: 1000),
                              description: "save ur 30%",
                              isHot: false),
                PromocodeData(name: "COUPON20",
                              addingDate: Date(timeIntervalSinceNow: -2000),
                              estimatedDate: Date(timeIntervalSinceNow: 2000),
                              description: "save ur 20%",
                              isHot: false),
                PromocodeData(name: "COUPON10",
                              addingDate: Date(timeIntervalSinceNow: -3000),
                              estimatedDate: Date(timeIntervalSinceNow: 3000),
                              description: "save your 10% when spent more than 1000",
                              isHot: false),
                PromocodeData(name: "COUPON30",
                              addingDate: Date(timeIntervalSinceNow: -1000),
                              estimatedDate: Date(timeIntervalSinceNow: 1000),
                              description: "save ur 30%",
                              isHot: false),
                PromocodeData(name: "COUPON20",
                              addingDate: Date(timeIntervalSinceNow: -2000),
                              estimatedDate: Date(timeIntervalSinceNow: 2000),
                              description: "save ur 20%",
                              isHot: false),
                PromocodeData(name: "COUPON10",
                              addingDate: Date(timeIntervalSinceNow: -3000),
                              estimatedDate: Date(timeIntervalSinceNow: 3000),
                              description: "save your 10% when spent more than 1000",
                              isHot: false)
        ]
        _collections = [
            ShopCategoryData(name: "HOT 🔥",
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
            ShopCategoryData(name: "Food",
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
            ShopCategoryData(name: "Other",
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
        _collections?.forEach { category in
            category.shops.forEach { shop in
                shop.promocodes.append(contentsOf: promocodes)
            }
        }
    }
}

    // MARK: - Home Section Data Controller
extension ModelController {
    
    static private func createHomeDataController() -> HomeDataController {
        
        let controller = HomeDataController(collections: homeCollections)
        
        return controller
    }
    
    static private func updateHomeCollections() {
        
        _homeCollections = collections.reduce(into: [ShopCategoryData]()){ result, section in
            
            let shops = Array(section.shops.prefix(15))
            
            let reducedSection = ShopCategoryData(name: section.name,
                                             shops: shops)
            
            result.append(reducedSection)
        }
    }
    
}

    // MARK: - Favorites Section Data Controller

extension ModelController {
    
    static func updateFavoritesCollections(with collections: [ShopCategoryData]) {
        
        favoritesCollections = collections.sorted { $0.name < $1.name }
        NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
    }
    
//    static func updateFavoritesCollections(in section: SectionData) {
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//        
//            var favorites = favoritesCollections
//            
//            let shops = section.shops.reduce(into: [CellData]()) { result, cell in
//                if cell.isFavorite {
//                    result.append(cell)
//                }
//            }
//            
//            if let updateIndex = favorites.firstIndex(where: { $0.name == section.name }) {
//                
//                if shops.isEmpty {
//                    favorites.remove(at: updateIndex)
//                } else {
//                    favorites[updateIndex].shops = shops
//                }
//            } else if !shops.isEmpty {
//                    favorites.append(SectionData(name: section.name, shops: shops))
//            }
//            
//            favoritesCollections = favorites
//        }
//    }
    
    static func insertInFavorites(shop: ShopData) {
        
        let section = collections.first { section in
            if section.shops.contains(shop) {
                return true
            }
            return false
        }
        
        if let sectionIndex = favoritesCollections.firstIndex(where: { $0.name == section!.name }) {
            favoritesCollections[sectionIndex].shops.append(shop)
        } else {
            favoritesCollections.append(ShopCategoryData(name: section!.name, shops: [shop]))
            favoritesCollections.sort { $0.name < $1.name }
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
        
        if let sectionIndex = favoritesCollections.firstIndex(where: { $0.name == section!.name }) {
            if let removeIndex = favoritesCollections[sectionIndex].shops.firstIndex(where: { $0.identifier == shop.identifier }) {
                favoritesCollections[sectionIndex].shops.remove(at: removeIndex)
            }
            
            if favoritesCollections[sectionIndex].shops.isEmpty {
                favoritesCollections.remove(at: sectionIndex)
                favoritesCollections.sort { $0.name < $1.name }
            }
        }
        
        NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
        favoritesDataController.collectionsBySections = favoritesCollections
    }
    
    static func updateFavoritesCollections(in name: String, with addedCells: Set<ShopData> = []) {
            
        if let sectionIndex = favoritesCollections.firstIndex(where: { $0.name == name }) {
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
            favoritesCollections.append(ShopCategoryData(name: name, shops: Array(addedCells)))
        }
        
        favoritesCollections.sort { $0.name < $1.name }
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
        
        return ShopCategoryData(name: "Search", shops: shops)
    }
}
