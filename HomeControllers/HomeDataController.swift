//
//  HomeDataController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

protocol FavoritesUpdaterProtocol {
    func updateFavoritesCollections(in name: String,
                                    added addedCells: Set<ShopData>,
                                    deleted deletedCells: Set<ShopData>)
}

class HomeDataController {
    
    var collections: [ShopCategoryData] = []
    
    func section(for index: Int) -> ShopCategoryData? {
        return ModelController.section(for: index)
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(HomeDataController.updateCollections), name: .didUpdateCollections, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didUpdateCollections, object: nil)
    }
 }

    // MARK: - FavoritesUpdaterProtocol
extension HomeDataController: FavoritesUpdaterProtocol {
    
    func updateFavoritesCollections(in name: String,
                                    added addedCells: Set<ShopData>,
                                    deleted deletedCells: Set<ShopData>) {
        ModelController.updateFavoritesCollections(in: name,
                                                   added: addedCells,
                                                   deleted: deletedCells)
    }
}

    // MARK: - Updating
extension HomeDataController {
    
    @objc func updateCollections() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let collections = ModelController.collections.reduce(into: [ShopCategoryData]()){ result, section in
            
                let shops = Array(section.shops.prefix(10))
    
                let reducedSection = ShopCategoryData(categoryName: section.categoryName,
                                                 shops: shops)
    
                result.append(reducedSection)
            }
           
            self?.collections = collections
            NotificationCenter.default.post(name: .didUpdateHome, object: nil)
        }
        
    }
}
