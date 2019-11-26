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
    
    static fileprivate var _homeDataController: HomeDataController?
    
    static var homeDataController: HomeDataController {
        
        if _homeDataController == nil {
            _homeDataController = createHomeDataController()
        }
        
        return _homeDataController!
    }
    
    static fileprivate var _favoritesDataController: FavoritesDataController?
    
    static var favoritesDataController: HomeDataController {
        
        if _favoritesDataController == nil {
            _favoritesDataController = createFavoritesDataController()
        }
        
        return _homeDataController!
    }
    
    static fileprivate var _favoritesCollections: [SectionData]?
    
    static var favoritesCollections: [SectionData] {
        
        if _favoritesCollections == nil {
            _favoritesCollections = createFavoritesCollections()
        }
        
        return _favoritesCollections!
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
    
    static private func createFavoritesDataController() -> FavoritesDataController {
        
        let controller = FavoritesDataController(collections: favoritesCollections)
        
        return controller
    }
}
