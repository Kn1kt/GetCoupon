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
                            cells: [HomeCellData(image: nil,
                                                 title: "Delivery Club",
                                                 subtitle: "Safe your 35%"),
                                    HomeCellData(image: nil,
                                                 title: "Yandex Food",
                                                 subtitle: "Safe your 15%"),
                                    HomeCellData(image: nil,
                                                 title: "Water Park Caribbean",
                                                 subtitle: "Your have personal coupon"),
                                    HomeCellData(image: nil,
                                                 title: "Ozon",
                                                 subtitle: "Safe your 25%"),
                                    HomeCellData(image: nil,
                                                 title: "AliExpress",
                                                 subtitle: "Safe your 60%"),
                                    HomeCellData(image: nil,
                                                 title: "ASOS",
                                                 subtitle: "Your have personal coupon"),
                                    HomeCellData(image: nil,
                                                 title: "Amazon",
                                                 subtitle: "Safe your 30%"),
                                    HomeCellData(image: nil,
                                                 title: "Apple",
                                                 subtitle: "Special inventational")]),
            HomeSectionData(sectionTitle: "Food",
                            cells: [HomeCellData(image: nil,
                                                 title: "KFC",
                                                 subtitle: "Two for one price"),
                                    HomeCellData(image: nil,
                                                 title: "McDonald's",
                                                 subtitle: "New menu"),
                                    HomeCellData(image: nil,
                                                 title: "Yakitoria",
                                                 subtitle: "Safe your 10%")
            ])
        ]
    }
}
