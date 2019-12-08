//
//  HomeDataController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

protocol FavoritesUpdaterProtocol {
    
    func updateFavoritesCollections(in name: String, with addedCells: Set<ShopData>)
    //func updateFavoritesCollections(in section: SectionData)
}

class HomeDataController {
    
    fileprivate var _collections: [ShopCategoryData] = []
    
    var collections: [ShopCategoryData] {
        return _collections
    }
    
    init(collections: [ShopCategoryData]) {
        self._collections = collections
    }
    
    func section(for index: Int) -> ShopCategoryData? {
        return ModelController.section(for: index)
    }
 }

// MARK: - FavoritesUpdaterProtocol

extension HomeDataController: FavoritesUpdaterProtocol {
    
    func updateFavoritesCollections(in name: String, with addedCells: Set<ShopData>) {
        ModelController.updateFavoritesCollections(in: name, with: addedCells)
    }
    
//    func updateFavoritesCollections(in section: SectionData) {
//        ModelController.updateFavoritesCollections(in: section)
//    }
}

// Just for test while receive parser
extension HomeDataController {
    
    func generateCollections() {
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
    }
}
