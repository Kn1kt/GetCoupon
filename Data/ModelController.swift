//
//  Model.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 25.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ModelController {
    
    static fileprivate var _collections: [SectionData] = []
    
    static private var _homeDataController: HomeDataController?
    
    static var homeDataController: HomeDataController {
        
        if _homeDataController == nil {
            _homeDataController = createHomeDataController()
        }
        
        return _homeDataController!
    }
    
    static private var _favoritesDataController: FavoritesDataController?
    
    static var favoritesDataController: FavoritesDataController {
        
        if _favoritesDataController == nil {
            _favoritesDataController = createFavoritesDataController()
        }
        
        return _favoritesDataController!
    }
    
    static private var _favoritesCollections: [SectionData] = []
    static private let favoritesQueue = DispatchQueue(label: "favoritesQueue", attributes: .concurrent)
    static var needUpdateFavoritesController: Bool = false
    static var favoritesCollections: [SectionData] {
    
        get {
            favoritesQueue.sync {
                return _favoritesCollections
            }
        }
        
        set {
            favoritesQueue.async(flags: .barrier) {
                self._favoritesCollections = newValue
                if needUpdateFavoritesController {
                    needUpdateFavoritesController = false
                    favoritesDataController.collectionsBySections = newValue
                }
                //NotificationCenter.default.post(name: <#T##NSNotification.Name#>, object: <#T##Any?#>, userInfo: <#T##[AnyHashable : Any]?#>)
            }
        }
    }
}

// MARK: - Data Management
extension ModelController {
    
    static func updateCollections() {
        
        // There gonna be some database query methods
        
        generateCollections()
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
        
        let controller = HomeDataController(collections: _collections)
        
        return controller
    }
}

// MARK: - Favorites Section Data Controller

extension ModelController {
    
    static private func createFavoritesCollections() -> [SectionData] {
        
        return _collections.reduce(into: [SectionData]()) { result, section in
            
            let cells = section.cells.reduce(into: [CellData]()) { result, cell in
                guard cell.isFavorite else {
                    return
                }
                result.append(cell)
            }
            
            if !cells.isEmpty {
                result.append(SectionData(sectionTitle: section.sectionTitle, cells: cells))
            }
        }
    }
    
    static func updateFavoritesCollections(with collections: [SectionData]) {
        
        favoritesCollections = collections
    }
    
    static func updateFavoritesCollections(in section: SectionData) {
        
        DispatchQueue.global(qos: .userInitiated).async {
        
            var favorites = favoritesCollections
            
            let cells = section.cells.reduce(into: [CellData]()) { result, cell in
                if cell.isFavorite {
                    result.append(cell)
                }
            }
            
            if let updateIndex = favorites.firstIndex(where: { $0.sectionTitle == section.sectionTitle }) {
                
                if cells.isEmpty {
                    favorites.remove(at: updateIndex)
                } else {
                    favorites[updateIndex].cells = cells
                }
            } else if !cells.isEmpty {
                    favorites.append(SectionData(sectionTitle: section.sectionTitle, cells: cells))
            }
            
            favoritesCollections = favorites
        }
    }
    
    static func updateFavoritesCollections(in sectionTitle: String, with addedCells: Set<CellData> = []) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            var favorites = favoritesCollections
            
            if let sectionIndex = favorites.firstIndex(where: { $0.sectionTitle == sectionTitle }) {
                let section = favorites[sectionIndex]
                
                var reduced = section.cells.filter { $0.isFavorite }
                
                reduced.append(contentsOf: addedCells)
                
                if reduced.isEmpty {
                    favorites.remove(at: sectionIndex)
                } else {
                    section.cells = reduced
                    favorites[sectionIndex] = section
                }
                
            } else {
                favorites.append(SectionData(sectionTitle: sectionTitle, cells: Array(addedCells)))
            }
            needUpdateFavoritesController = true
            favoritesCollections = favorites
        }
        
    }
    
    static private func createFavoritesDataController() -> FavoritesDataController {
        
        let controller = FavoritesDataController(collections: favoritesCollections)
        
        return controller
    }
}
