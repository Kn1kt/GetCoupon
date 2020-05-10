//
//  SearchMainViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 04.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchMainViewController: SearchBaseViewController {
  
  private var resultsViewController: SearchResultsViewController!
  
  private var searchController: UISearchController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    resultsViewController = SearchResultsViewController()
    
    searchController = UISearchController(searchResultsController: resultsViewController)
    searchController.searchResultsUpdater = self
    searchController.searchBar.autocapitalizationType = .none
    
    searchController.searchBar.delegate = self
    
    definesPresentationContext = true
    
    navigationItem.searchController = searchController
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.title = "Search"
    navigationItem.hidesSearchBarWhenScrolling = false
    
  }
}


  // MARK: - UISearchBarDelegate
extension SearchMainViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}

  // MARK: - UISearchResultsUpdating
extension SearchMainViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    guard let resultsController = searchController.searchResultsController as? SearchResultsViewController,
      let filter = searchController.searchBar.text?.trimmingCharacters(in: CharacterSet.whitespaces) else {
        return
    }
    resultsController.viewModel.searchText.accept(filter)
  }
}
