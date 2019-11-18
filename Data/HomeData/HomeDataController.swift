//
//  HomeDataController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class HomeDataController {
    
    fileprivate var _collections: [HomeSectionData] = []
    
    var collections: [HomeSectionData] {
        return _collections
    }
    
    init() {
        generateCollections()
    }
}

// Just for test while receive parse
extension HomeDataController {
    
    func generateCollections() {
        _collections = [
            HomeSectionData(sectionTitle: "HOT 🔥",
                            cells: [HomeCellData(image: UIImage(named: "Delivery"),
                                                 title: "Delivery Club",
                                                 subtitle: "Safe your 35%"),
                                    HomeCellData(image: UIImage(named: "Yandex"),
                                                 title: "Yandex Food",
                                                 subtitle: "Safe your 15%"),
                                    HomeCellData(image: UIImage(named: "WaterPark"),
                                                 title: "Water Park Caribbean",
                                                 subtitle: "Your have personal coupon"),
                                    HomeCellData(image: UIImage(named: "Ozon"),
                                                 title: "Ozon",
                                                 subtitle: "Safe your 25%"),
                                    HomeCellData(image: UIImage(named: "AliExpress"),
                                                 title: "AliExpress",
                                                 subtitle: "Safe your 60%"),
                                    HomeCellData(image: UIImage(named: "ASOS"),
                                                 title: "ASOS",
                                                 subtitle: "Your have personal coupon"),
                                    HomeCellData(image: UIImage(named: "Amazon"),
                                                 title: "Amazon",
                                                 subtitle: "Safe your 30%"),
                                    HomeCellData(image: UIImage(named: "Apple"),
                                                 title: "Apple",
                                                 subtitle: "Special inventational")]),
            HomeSectionData(sectionTitle: "Food",
                            cells: [HomeCellData(image: UIImage(named: "KFC"),
                                                 title: "KFC",
                                                 subtitle: "Two for one price"),
                                    HomeCellData(image: UIImage(named: "McDonald's"),
                                                 title: "McDonald's",
                                                 subtitle: "New menu"),
                                    HomeCellData(image: UIImage(named: "Yakitoria"),
                                                 title: "Yakitoria",
                                                 subtitle: "Safe your 10%")
            ])
        ]
    }
}
