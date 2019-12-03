//
//  tst.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 24.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//


import UIKit

struct Promoсode: Decodable {

    let name: String //= "Some Coupon"
    let estimatedDate: String?
    let description: String? //= "Short decription"
    let websiteLink: String //= "Link"
    let isHot: Bool //= false
}

struct Shop: Decodable {

    let name: String //= "Shop Name"
    let description: String? //= "Full description"
    let shortDescription: String //= "Short description"

    let websiteLink: String //= "www.ShopName.com"

    let imageLink: String? //= ".../fullImage"
    let previewImageLink: String? //= ".../previewImage"

    let promocodes: [Promoсode] //= []
}

struct ShopCategory: Decodable {

    let name: String //= "Category Name"

    let tags: [String] //= []

    let shops: [Shop] //= []
}

struct Model {

    let categories: [ShopCategory] = []
}



//// FOR TESTS
//func generateCollections() {
//        let _collections = [
//            SectionData(sectionTitle: "HOT 🔥",
//                            cells: [CellData(image: UIImage(named: "Delivery"),
//                                             title: "Delivery Club",
//                                             subtitle: "Save your 35%"),
//                                    CellData(image: UIImage(named: "Yandex"),
//                                             title: "Yandex Food",
//                                             subtitle: "Save your 15%"),
//                                    CellData(image: UIImage(named: "WaterPark"),
//                                             title: "Water Park Caribbean",
//                                             subtitle: "Your have personal coupon"),
//                                    CellData(image: UIImage(named: "Ozon"),
//                                             title: "Ozon",
//                                             subtitle: "Save your 25%"),
//                                    CellData(image: UIImage(named: "AliExpress"),
//                                             title: "AliExpress",
//                                             subtitle: "Save your 60%"),
//                                    CellData(image: UIImage(named: "ASOS"),
//                                             title: "ASOS",
//                                             subtitle: "Your have personal coupon"),
//                                    CellData(image: UIImage(named: "Amazon"),
//                                             title: "Amazon",
//                                             subtitle: "Save your 30%"),
//                                    CellData(image: UIImage(named: "Apple"),
//                                             title: "Apple",
//                                             subtitle: "Special inventational")]),
//            SectionData(sectionTitle: "Food",
//                            cells: [CellData(image: UIImage(named: "KFC"),
//                                             title: "KFC",
//                                             subtitle: "Two for one price"),
//                                    CellData(image: UIImage(named: "McDonald's"),
//                                             title: "McDonald's",
//                                             subtitle: "New menu"),
//                                    CellData(image: UIImage(named: "Yakitoria"),
//                                             title: "Yakitoria",
//                                             subtitle: "Save your 10%"),
//                                    CellData(image: UIImage(named: "KFC"),
//                                             title: "KFC",
//                                             subtitle: "Two for one price"),
//                                    CellData(image: UIImage(named: "McDonald's"),
//                                             title: "McDonald's",
//                                             subtitle: "New menu"),
//                                    CellData(image: UIImage(named: "Yakitoria"),
//                                             title: "Yakitoria",
//                                             subtitle: "Save your 10%")]),
//            SectionData(sectionTitle: "Other",
//                            cells: [CellData(image: UIImage(named: "Amazon"),
//                                             title: "Amazon",
//                                             subtitle: "Save your 30%"),
//                                    CellData(image: UIImage(named: "Apple"),
//                                             title: "Apple",
//                                             subtitle: "Special inventational"),
//                                    CellData(image: UIImage(named: "AliExpress"),
//                                             title: "AliExpress",
//                                             subtitle: "Save your 60%"),
//                                    CellData(image: UIImage(named: "ASOS"),
//                                             title: "ASOS",
//                                             subtitle: "Your have personal coupon")])
//        ]
//}
