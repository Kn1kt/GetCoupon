//
//  FavoritesDataController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 25.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class FavoritesDataController {
    
    fileprivate var _collectionsBySections: [SectionData] = []
    fileprivate var _collectionsByDates: [CellData] = []
    
    var collectionsBySections: [SectionData] {
        return _collectionsBySections
    }
    
    var collectionsByDates: [CellData] {
        return _collectionsByDates
    }
    
    init(collections: [SectionData]) {
        self._collectionsBySections = collections
        setupCollectionsByDates()
    }
    
    private func setupCollectionsByDates() {
        
        _collectionsBySections.forEach { section in
            let cells = section.cells.filter { cell in
                 return cell.isFavorite
            }
            _collectionsByDates.append(contentsOf: cells)
        }
        
        _collectionsByDates.sort { lhs, rhs in
            return lhs.favoriteAddingDate! < rhs.favoriteAddingDate!
        }
    }
}

// MARK: - Collections Management

extension FavoritesDataController {
    
    func add(item: CellData, in section: String) {
        _collectionsByDates.append(item)
        
        for sectionIndex in _collectionsBySections.indices {
            
            if _collectionsBySections[sectionIndex].sectionTitle == section {
                _collectionsBySections[sectionIndex].cells.append(item)
                break
            }
        }
    }
    
    func remove(item: CellData, from section: String) {
        if let removeIndex = _collectionsByDates.firstIndex(of: item) {
            _collectionsByDates.remove(at: removeIndex)
        }
        
        for sectionIndex in _collectionsBySections.indices {
            
            if _collectionsBySections[sectionIndex].sectionTitle == section {
                
                if let removeIndex = _collectionsBySections[sectionIndex].cells.firstIndex(of: item) {
                    _collectionsBySections[sectionIndex].cells.remove(at: removeIndex)
                }
                break
            }
        }
    }
}
