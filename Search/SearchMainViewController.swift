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
        resultsViewController.section = ShopCategoryData(categoryName: "Results")
        
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
        let selectedShop: ShopData
        
        if collectionView === self.collectionView {
            selectedShop = section.shops[indexPath.row]
        } else {
            selectedShop = resultsViewController.section.shops[indexPath.row]
        }
        
        // There gonna be some presentation features
        //debugPrint(selectedShop)
//        let shop = ShopData(name: "KFC",
//                            description: "Menu: chicken dishes, french fries, salads, snacks, etc.",
//                            shortDescription: "Kentucky Fried Chicken",
//                            websiteLink: "//kindaLink",
//                            image: UIImage(named: "KFC"),
//                            previewImage: UIImage(named: "KFC"),
//                            isFavorite: true,
//                            promocodes: [
//                                PromocodeData(name: "COUPON30",
//                                              addingDate: Date(timeIntervalSinceNow: -1000),
//                                              estimatedDate: Date(timeIntervalSinceNow: 1000),
//                                              description: "save ur 30%",
//                                              isHot: false),
//                                PromocodeData(name: "COUPON20",
//                                              addingDate: Date(timeIntervalSinceNow: -2000),
//                                              estimatedDate: Date(timeIntervalSinceNow: 2000),
//                                              description: "save ur 20%",
//                                              isHot: false),
//                                PromocodeData(name: "COUPON10",
//                                              addingDate: Date(timeIntervalSinceNow: -3000),
//                                              estimatedDate: Date(timeIntervalSinceNow: 3000),
//                                              description: "save your 10% when spent more than 1000",
//                                              isHot: false),
//                                PromocodeData(name: "COUPON30",
//                                              addingDate: Date(timeIntervalSinceNow: -1000),
//                                              estimatedDate: Date(timeIntervalSinceNow: 1000),
//                                              description: "save ur 30%",
//                                              isHot: false),
//                                PromocodeData(name: "COUPON20",
//                                              addingDate: Date(timeIntervalSinceNow: -2000),
//                                              estimatedDate: Date(timeIntervalSinceNow: 2000),
//                                              description: "save ur 20%",
//                                              isHot: false),
//                                PromocodeData(name: "COUPON10",
//                                              addingDate: Date(timeIntervalSinceNow: -3000),
//                                              estimatedDate: Date(timeIntervalSinceNow: 3000),
//                                              description: "save your 10% when spent more than 1000",
//                                              isHot: false),
//                                PromocodeData(name: "COUPON30",
//                                              addingDate: Date(timeIntervalSinceNow: -1000),
//                                              estimatedDate: Date(timeIntervalSinceNow: 1000),
//                                              description: "save ur 30%",
//                                              isHot: false),
//                                PromocodeData(name: "COUPON20",
//                                              addingDate: Date(timeIntervalSinceNow: -2000),
//                                              estimatedDate: Date(timeIntervalSinceNow: 2000),
//                                              description: "save ur 20%",
//                                              isHot: false),
//                                PromocodeData(name: "COUPON10",
//                                              addingDate: Date(timeIntervalSinceNow: -3000),
//                                              estimatedDate: Date(timeIntervalSinceNow: 3000),
//                                              description: "save your 10% when spent more than 1000",
//                                              isHot: false)
//        ])
        
        let viewController = ShopViewController(shop: selectedShop)
        let navController = UINavigationController(rootViewController: viewController)
        //navController.modalPresentationStyle = .fullScreen
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
        resultsController.section.shops = filtered
        resultsController.updateSnapshot()
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
