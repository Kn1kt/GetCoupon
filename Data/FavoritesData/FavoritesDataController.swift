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
    
    var collectionsBySections: [SectionData] = [] {
        didSet {
            needUpdateDates = true
            snapshotUpdater?.needUpdateSnapshot = true
        }
    }
    
    private var _collectionsByDates: [CellData] = []
    
    var collectionsByDates: [CellData] {
        get {
            if needUpdateDates {
                needUpdateDates = false
                setupCollectionsByDates()
            }
            
            return _collectionsByDates
        }
    }
    
    init(collections: [SectionData]) {
        collectionsBySections = collections
        snapshotUpdater?.needUpdateSnapshot = true
    }
    
    private func setupCollectionsByDates() {
        
        _collectionsByDates = []
        collectionsBySections.forEach { section in
            _collectionsByDates.append(contentsOf: section.cells)
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
            let cells = section.cells.filter { cell in
                if !cell.isFavorite {
                    cell.favoriteAddingDate = nil
                    needUpdate = true
                    return false
                }
                
                return true
            }
            
            if cells.isEmpty {
                return false
            } else if cells.count != section.cells.count {
                section.cells = cells
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
    
    func filteredCollectionBySections(with filter: String) -> [SectionData] {
        
        if filter.isEmpty {
            return collectionsBySections
        }
        let lowercasedFilter = filter.lowercased()
        
        let filtered = collectionsBySections.reduce(into: [SectionData]()) { result, section in
            let cells = section.cells.filter { cell in
                return cell.title.lowercased().contains(lowercasedFilter)
            }
            
            if !cells.isEmpty {
                result.append(SectionData(sectionTitle: section.sectionTitle, cells: cells.sorted { $0.title < $1.title }))
            }
            
        }
        
        return filtered
    }
    
    func filteredCollectionByDates(with filter: String) -> [CellData] {
        
        if filter.isEmpty {
            return collectionsByDates
        }
        let lowercasedFilter = filter.lowercased()
        
        let filtered = collectionsByDates.filter { cell in
                return cell.title.lowercased().contains(lowercasedFilter)
        }
        
        return filtered
    }
}