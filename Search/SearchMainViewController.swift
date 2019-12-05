//
//  SearchMainViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 04.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class SearchMainViewController: SearchBaseViewController {
    
    /// NSPredicate expressions keys
    private enum ExpressionKeys: String {
        case title
        case tags
    }
    
    private var resultsViewController: SearchResultsViewController!
    
    private var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resultsViewController = SearchResultsViewController()
        
        section = ModelController.searchCollection
        resultsViewController.section = SectionData(sectionTitle: "Results")
        
        collectionView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Search"
        navigationItem.hidesSearchBarWhenScrolling = false
        
        updateSnapshot()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // There gonna be some restoring features
    }
}

    // MARK: - UICollectionViewDelegate

extension SearchMainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell: CellData
        
        if collectionView === self.collectionView {
            selectedCell = section.cells[indexPath.row]
        } else {
            selectedCell = resultsViewController.section.cells[indexPath.row]
        }
        
        // There gonna be some presentation features
        
        debugPrint(selectedCell)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

    // MARK: - UISearchBarDelegate

extension SearchMainViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

     // MARK: - UISearchControllerDelegate

extension SearchMainViewController: UISearchControllerDelegate {

//    func presentSearchController(_ searchController: UISearchController) {
//        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
//    }

    func willPresentSearchController(_ searchController: UISearchController) {
        resultsViewController.collectionView.delegate = self
    }
//
//    func didPresentSearchController(_ searchController: UISearchController) {
//        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
//    }
//
//    func willDismissSearchController(_ searchController: UISearchController) {
//        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
//    }
//
//    func didDismissSearchController(_ searchController: UISearchController) {
//        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
//    }
}

    // MARK: - UISearchResultsUpdating

extension SearchMainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController,
            let filter = searchController.searchBar.text?.trimmingCharacters(in: CharacterSet.whitespaces) else {
            return
        }
        
        let filtered = filteredCollection(with: filter)
        resultsController.section.cells = filtered
        resultsController.updateSnapshot()
    }
    
    private func filteredCollection(with filter: String) -> [CellData] {
        
        if filter.isEmpty {
            return section.cells
        }
        let lowercasedFilter = filter.lowercased()
        
        let filtered = section.cells.filter { cell in
                return cell.title.lowercased().contains(lowercasedFilter)
        }
        
        return filtered.sorted { $0.title < $1.title }
    }
    
}
