//
//  HomeDataController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

protocol FavoritesUpdaterProtocol {
    
    func updateFavoritesCollections(in sectionTitle: String, with addedCells: Set<CellData>)
    //func updateFavoritesCollections(in section: SectionData)
}

class HomeDataController {
    
    fileprivate var _collections: [SectionData] = []
    
    var collections: [SectionData] {
        return _collections
    }
    
    init(collections: [SectionData]) {
        self._collections = collections
    }
}

// MARK: - FavoritesUpdaterProtocol

extension HomeDataController: FavoritesUpdaterProtocol {
    
    func updateFavoritesCollections(in sectionTitle: String, with addedCells: Set<CellData>) {
        ModelController.updateFavoritesCollections(in: sectionTitle, with: addedCells)
    }
    
    func updateFavoritesCollections(in section: SectionData) {
        ModelController.updateFavoritesCollections(in: section)
    }
}

// Just for test while receive parse
extension HomeDataController {
    
    func generateCollections() {
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
