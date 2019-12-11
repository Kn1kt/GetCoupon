//
//  FavoritesDataController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 25.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

protocol SnapshotUpdaterProtocol {
    var needUpdateSnapshot: Bool { get set }
}

class FavoritesDataController {
    
    var snapshotUpdater: SnapshotUpdaterProtocol?
    
    var needUpdateDates: Bool = true
    
    private var _collectionsBySections: [ShopCategoryData] = []
    
    private let collectionsBySectionsQueue = DispatchQueue(label: "collectionsBySectionsQueue", attributes: .concurrent)
    var collectionsBySections: [ShopCategoryData] {
        get {
            collectionsBySectionsQueue.sync {
                return _collectionsBySections
            }
        }
        
        set {
            collectionsBySectionsQueue.async(flags: .barrier) { [weak self] in
                self?._collectionsBySections = newValue
            }
            needUpdateDates = true
            snapshotUpdater?.needUpdateSnapshot = true
        }
    }
    
//    var collectionsBySections: [ShopCategoryData] = [] {
//        didSet {
//            needUpdateDates = true
//            snapshotUpdater?.needUpdateSnapshot = true
//        }
//    }
    
    private var _collectionsByDates: [ShopData] = []
    
    var collectionsByDates: [ShopData] {
        get {
            if needUpdateDates {
                needUpdateDates = false
                setupCollectionsByDates()
            }
            
            return _collectionsByDates
        }
    }
    
    init(collections: [ShopCategoryData]) {
        collectionsBySections = collections
        snapshotUpdater?.needUpdateSnapshot = true
    }
    
    private func setupCollectionsByDates() {
        
        _collectionsByDates = []
        collectionsBySections.forEach { section in
            _collectionsByDates.append(contentsOf: section.shops)
        }
        
        _collectionsByDates.sort { lhs, rhs in
            return lhs.favoriteAddingDate! > rhs.favoriteAddingDate!
        }
    }
}

    // MARK: - Collections Management

extension FavoritesDataController {
    
    func checkCollection() {
        var needUpdate = false
        
        let filtered = collectionsBySections.filter { section in
            let shops = section.shops.filter { cell in
                if !cell.isFavorite {
                    cell.favoriteAddingDate = nil
                    needUpdate = true
                    return false
                }
                
                return true
            }
            
            if shops.isEmpty {
                return false
            } else if shops.count != section.shops.count {
                section.shops = shops
            }
            
            return true
        }
        
        if needUpdate {
            collectionsBySections = filtered
            ModelController.updateFavoritesCollections(with: filtered)
        }
    }
}

    // MARK: - Search
extension FavoritesDataController {
    
    func filteredCollectionBySections(with filter: String) -> [ShopCategoryData] {
        
        if filter.isEmpty {
            return collectionsBySections
        }
        let lowercasedFilter = filter.lowercased()
        
        let filtered = collectionsBySections.reduce(into: [ShopCategoryData]()) { result, section in
            let shops = section.shops.filter { cell in
                return cell.name.lowercased().contains(lowercasedFilter)
            }
            
            if !shops.isEmpty {
                result.append(ShopCategoryData(categoryName: section.categoryName, shops: shops.sorted { $0.name < $1.name }))
            }
            
        }
        
        return filtered
    }
    
    func filteredCollectionByDates(with filter: String) -> [ShopData] {
        
        if filter.isEmpty {
            return collectionsByDates
        }
        let lowercasedFilter = filter.lowercased()
        
        let filtered = collectionsByDates.filter { cell in
                return cell.name.lowercased().contains(lowercasedFilter)
        }
        
        return filtered
    }
}
