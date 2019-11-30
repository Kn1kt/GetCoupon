//
//  FavoritesDataController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 25.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

protocol SnapshotUpdaterProtocol {
    func updateSnapshot()
}

class FavoritesDataController {
    
    var snapshotUpdater: SnapshotUpdaterProtocol?
    
    private var _collectionsBySections: [SectionData] = []
    
    private let collectionBySectionQueue = DispatchQueue(label: "collectionBySectionQueue", attributes: .concurrent)
    var collectionsBySections: [SectionData] {
        get {
            collectionBySectionQueue.sync {
                return _collectionsBySections
            }
        }
        
        set {
            collectionBySectionQueue.async(flags: .barrier) { [unowned self] in
                self._collectionsBySections = newValue
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    guard let self = self else { return }
                    self.setupCollectionsByDates()
                }
            }
        }
    }
    
    private var _collectionsByDates: [CellData] = []
    
    private let collectionByDateQueue = DispatchQueue(label: "collectionByDateQueue", attributes: .concurrent)
    var collectionsByDates: [CellData] {
        get {
            collectionByDateQueue.sync {
                return _collectionsByDates
            }
        }
        
        set {
            collectionByDateQueue.async(flags: .barrier) {
                [unowned self] in
                self._collectionsByDates = newValue
            }
        }
        
    }
    
    init(collections: [SectionData]) {
        _collectionsBySections = collections
        setupCollectionsByDates()
    }
    
    private func setupCollectionsByDates() {
        
        var newCollection: [CellData] = []
        let bySections = collectionsBySections
        bySections.forEach { section in
            newCollection.append(contentsOf: section.cells)
        }
        
        _collectionsByDates = newCollection.sorted { lhs, rhs in
            return lhs.favoriteAddingDate! < rhs.favoriteAddingDate!
        }
        

        snapshotUpdater?.updateSnapshot()

    }
}

// MARK: - Collections Management

extension FavoritesDataController {
    
    func checkCollection() {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var needUpdate = false
            
            let collection = self.collectionsBySections
            let filtered = collection.filter { section in
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
                self.collectionsBySections = filtered
                ModelController.favoritesCollections = filtered
            }
        }
        
    }
    
    func updateModel() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            ModelController.favoritesCollections = self.collectionsBySections
        }
    }
    
    func remove(at index: (section: Int?, row: Int?)) {
        
        switch index {
        case let (section?, row?):
            let cell = collectionsBySections[section].cells.remove(at: row)
            cell.isFavorite = false
            cell.favoriteAddingDate = nil
            
            if collectionsBySections[section].cells.isEmpty {
                collectionsBySections.remove(at: section)
            }
            
            collectionsByDates = collectionsByDates.filter { $0.isFavorite }
            
        case let (_, row?):
            let cell = collectionsByDates.remove(at: row)
            cell.isFavorite = false
            cell.favoriteAddingDate = nil
            
            if collectionsByDates.isEmpty {
                collectionsBySections = []
                return
            }
            collectionsBySections = collectionsBySections.filter { section in
                let cells = section.cells.filter { cell in
                    return cell.isFavorite
                }
                
                if cells.isEmpty {
                    return false
                } else if cells.count != section.cells.count {
                    section.cells = cells
                }
                
                return true
            }
            
        default:
            fatalError("Can't remove element if FavoritesDataController")
        }
    }

//    func add(item: CellData, in section: String) {
//        _collectionsByDates.append(item)
//
//        for sectionIndex in _collectionsBySections.indices {
//
//            if _collectionsBySections[sectionIndex].sectionTitle == section {
//                _collectionsBySections[sectionIndex].cells.append(item)
//                break
//            }
//        }
//    }
//
//    func remove(item: CellData, from section: String) {
//        if let removeIndex = _collectionsByDates.firstIndex(of: item) {
//            _collectionsByDates.remove(at: removeIndex)
//        }
//
//        for sectionIndex in _collectionsBySections.indices {
//
//            if _collectionsBySections[sectionIndex].sectionTitle == section {
//
//                if let removeIndex = _collectionsBySections[sectionIndex].cells.firstIndex(of: item) {
//                    _collectionsBySections[sectionIndex].cells.remove(at: removeIndex)
//                }
//                break
//            }
//        }
//    }
}
