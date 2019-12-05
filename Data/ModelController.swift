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
    static fileprivate var _collections: [SectionData]?
    
    static var collections: [SectionData] {
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
    
    static private var _homeCollections: [SectionData]?
    
    static var homeCollections: [SectionData] {
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
    
    static private var favoritesCollections: [SectionData] = []
    
    /// Search Collection
    static private var _searchCollection: SectionData?
    
    static var searchCollection: SectionData {
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
    
    static func section(for index: Int) -> SectionData? {
        guard index >= 0, collections.count > index else { return nil }
        
        return collections[index]
    }
    
    
    /// FOR TESTS
    static func generateCollections() {
        _collections = [
            SectionData(sectionTitle: "HOT 🔥",
                            cells: [CellData(image: UIImage(named: "Delivery"),
                                             title: "Delivery Club",
                                             subtitle: "Save your 35%"),
                                    CellData(image: UIImage(named: "Yandex"),
                                             title: "Yandex Food",
                                             subtitle: "Save your 15%"),
                                    CellData(image: UIImage(named: "WaterPark"),
                                             title: "Water Park Caribbean",
                                             subtitle: "Your have personal coupon"),
                                    CellData(image: UIImage(named: "Ozon"),
                                             title: "Ozon",
                                             subtitle: "Save your 25%"),
                                    CellData(image: UIImage(named: "AliExpress"),
                                             title: "AliExpress",
                                             subtitle: "Save your 60%"),
                                    CellData(image: UIImage(named: "ASOS"),
                                             title: "ASOS",
                                             subtitle: "Your have personal coupon"),
                                    CellData(image: UIImage(named: "Amazon"),
                                             title: "Amazon",
                                             subtitle: "Save your 30%"),
                                    CellData(image: UIImage(named: "Apple"),
                                             title: "Apple",
                                             subtitle: "Special inventational")]),
            SectionData(sectionTitle: "Food",
                            cells: [CellData(image: UIImage(named: "KFC"),
                                             title: "KFC",
                                             subtitle: "Two for one price"),
                                    CellData(image: UIImage(named: "McDonald's"),
                                             title: "McDonald's",
                                             subtitle: "New menu"),
                                    CellData(image: UIImage(named: "Yakitoria"),
                                             title: "Yakitoria",
                                             subtitle: "Save your 10%"),
                                    CellData(image: UIImage(named: "KFC"),
                                             title: "KFC",
                                             subtitle: "Two for one price"),
                                    CellData(image: UIImage(named: "McDonald's"),
                                             title: "McDonald's",
                                             subtitle: "New menu"),
                                    CellData(image: UIImage(named: "McDonald's"),
                                             title: "McDonald's",
                                             subtitle: "New menu"),
                                    CellData(image: UIImage(named: "Yakitoria"),
                                             title: "Yakitoria",
                                             subtitle: "Save your 10%"),
                                    CellData(image: UIImage(named: "KFC"),
                                             title: "KFC",
                                             subtitle: "Two for one price"),
                                    CellData(image: UIImage(named: "McDonald's"),
                                             title: "McDonald's",
                                             subtitle: "New menu"),
                                    CellData(image: UIImage(named: "McDonald's"),
                                             title: "McDonald's",
                                             subtitle: "New menu"),
                                    CellData(image: UIImage(named: "Yakitoria"),
                                             title: "Yakitoria",
                                             subtitle: "Save your 10%"),
                                    CellData(image: UIImage(named: "KFC"),
                                             title: "KFC",
                                             subtitle: "Two for one price"),
                                    CellData(image: UIImage(named: "McDonald's"),
                                             title: "McDonald's",
                                             subtitle: "New menu"),
                                    CellData(image: UIImage(named: "Yakitoria"),
                                             title: "Yakitoria",
                                             subtitle: "Save your 10%")]),
            SectionData(sectionTitle: "Other",
                            cells: [CellData(image: UIImage(named: "Amazon"),
                                             title: "Amazon",
                                             subtitle: "Save your 30%"),
                            CellData(image: UIImage(named: "Apple"),
                                     title: "Apple",
                                     subtitle: "Special inventational"),
                            CellData(image: UIImage(named: "AliExpress"),
                                     title: "AliExpress",
                                     subtitle: "Save your 60%"),
                            CellData(image: UIImage(named: "ASOS"),
                                     title: "ASOS",
                                     subtitle: "Your have personal coupon")])
        ]
    }
}

    // MARK: - Home Section Data Controller
extension ModelController {
    
    static private func createHomeDataController() -> HomeDataController {
        
        let controller = HomeDataController(collections: homeCollections)
        
        return controller
    }
    
    static private func updateHomeCollections() {
        
        _homeCollections = collections.reduce(into: [SectionData]()){ result, section in
            
            let cells = Array(section.cells.prefix(5))
            
            let reducedSection = SectionData(sectionTitle: section.sectionTitle,
                                             cells: cells)
            
            result.append(reducedSection)
        }
    }
    
}

    // MARK: - Favorites Section Data Controller

extension ModelController {
    
    static func updateFavoritesCollections(with collections: [SectionData]) {
        
        favoritesCollections = collections.sorted { $0.sectionTitle < $1.sectionTitle }
        NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
    }
    
//    static func updateFavoritesCollections(in section: SectionData) {
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//        
//            var favorites = favoritesCollections
//            
//            let cells = section.cells.reduce(into: [CellData]()) { result, cell in
//                if cell.isFavorite {
//                    result.append(cell)
//                }
//            }
//            
//            if let updateIndex = favorites.firstIndex(where: { $0.sectionTitle == section.sectionTitle }) {
//                
//                if cells.isEmpty {
//                    favorites.remove(at: updateIndex)
//                } else {
//                    favorites[updateIndex].cells = cells
//                }
//            } else if !cells.isEmpty {
//                    favorites.append(SectionData(sectionTitle: section.sectionTitle, cells: cells))
//            }
//            
//            favoritesCollections = favorites
//        }
//    }
    
    static func updateFavoritesCollections(in sectionTitle: String, with addedCells: Set<CellData> = []) {
            
        if let sectionIndex = favoritesCollections.firstIndex(where: { $0.sectionTitle == sectionTitle }) {
            let section = favoritesCollections[sectionIndex]
            
            var reduced = section.cells.filter { cell in
                if addedCells.contains(cell) {
                    return false
                }
                
                return cell.isFavorite
            }
            
            reduced.append(contentsOf: addedCells)
            
            if reduced.isEmpty {
                favoritesCollections.remove(at: sectionIndex)
            } else {
                section.cells = reduced
            }
            
        } else {
            favoritesCollections.append(SectionData(sectionTitle: sectionTitle, cells: Array(addedCells)))
        }
        
        favoritesCollections.sort { $0.sectionTitle < $1.sectionTitle }
        favoritesDataController.collectionsBySections = favoritesCollections

        
    }
    
    static func removeAllFavorites() {
        
        guard !favoritesCollections.isEmpty else {
            return
        }
        
        favoritesCollections.forEach { section in
            section.cells.forEach { cell in
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
    
    static private func setupSearchData() -> SectionData {
        
        let cells = collections.reduce(into: [CellData]()) { result, section in
            result.append(contentsOf: section.cells)
        }
        
        return SectionData(sectionTitle: "Search", cells: cells)
    }
}
