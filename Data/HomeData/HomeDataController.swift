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
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(HomeDataController.updateCollections), name: .didUpdateCollections, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didUpdateCollections, object: nil)
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

    // MARK: - Updating
extension HomeDataController {
    
    @objc func updateCollections() {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let collections = ModelController.collections.reduce(into: [ShopCategoryData]()){ result, section in
            
                let shops = Array(section.shops.prefix(15))
    
                let reducedSection = ShopCategoryData(categoryName: section.categoryName,
                                                 shops: shops)
    
                result.append(reducedSection)
            }
            self?._collections = collections
            NotificationCenter.default.post(name: .didUpdateHome, object: nil)
        }
        
    }
}
