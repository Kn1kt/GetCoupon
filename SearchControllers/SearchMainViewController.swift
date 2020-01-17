//
//  SearchMainViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 04.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class SearchMainViewController: SearchBaseViewController {
    
    private var resultsViewController: SearchResultsViewController!
    
    private var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resultsViewController = SearchResultsViewController()
        
        section = ModelController.searchCollection
        resultsViewController.section = ShopCategoryData(categoryName: "Results")
        NotificationCenter.default.addObserver(self, selector: #selector(SearchMainViewController.updateSection), name: .didUpdateSearchCollections, object: nil)
        
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didUpdateSearchCollections, object: nil)
    }
}

    // MARK: - UICollectionViewDelegate
extension SearchMainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedShop: ShopData
        
        if collectionView === self.collectionView {
            selectedShop = section.shops[indexPath.row]
        } else {
            selectedShop = resultsViewController.section.shops[indexPath.row]
        }
        
        let viewController = ShopViewController(shop: selectedShop)
        let navController = UINavigationController(rootViewController: viewController)
        present(navController, animated: true)
        
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

    func willPresentSearchController(_ searchController: UISearchController) {
        resultsViewController.collectionView.delegate = self
    }
}

    // MARK: - UISearchResultsUpdating
extension SearchMainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController,
            let filter = searchController.searchBar.text?.trimmingCharacters(in: CharacterSet.whitespaces) else {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let filtered = self.filteredCollection(with: filter)
            
            DispatchQueue.main.async {
                resultsController.section.shops = filtered
                resultsController.updateSnapshot()
            }
        }
    }
    
    private func filteredCollection(with filter: String) -> [ShopData] {
        
        if filter.isEmpty {
            return section.shops
        }
        let lowercasedFilter = filter.lowercased()
        
        let filtered = section.shops.filter { cell in
                return cell.name.lowercased().contains(lowercasedFilter)
        }
        
        return filtered.sorted { $0.name < $1.name }
    }
    
}

    // MARK: - Data Updating
extension SearchMainViewController {
    
    @objc func updateSection() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.section = ModelController.searchCollection
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let currentVC = self.navigationController?.tabBarController?.selectedIndex,
                    currentVC == 2 {
                    self.updateSnapshot()
                } else {
                    self.needUpdateSnapshot = true
                }
            }
        }
        
    }
}
