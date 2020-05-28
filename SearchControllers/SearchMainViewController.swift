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

class SearchMainViewController: UIViewController {
  
  static let titleElementKind = "title-element-kind"
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private let viewModel = SearchViewModel()
  
  private var resultsViewController: SearchResultsViewController!
  
  private var searchController: UISearchController!
  
  private var collectionView: UICollectionView! = nil
  private var dataSource: UICollectionViewDiffableDataSource
    <SuggestedSearchCategoryData, SuggestedSearchCellData>! = nil
  private var currentSnapshot: NSDiffableDataSourceSnapshot
    <SuggestedSearchCategoryData, SuggestedSearchCellData>! = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.tintColor = UIColor(named: "BlueTintColor")
    
    resultsViewController = SearchResultsViewController()
    
    searchController = UISearchController(searchResultsController: resultsViewController)
    searchController.delegate = self
    searchController.searchResultsUpdater = self
    searchController.searchBar.autocapitalizationType = .none
    searchController.searchBar.searchTextField.tokenBackgroundColor = UIColor(named: "BlueTintColor")
    searchController.searchBar.delegate = self
    searchController.automaticallyShowsSearchResultsController = false
    
    resultsViewController.searchController = searchController
    
    definesPresentationContext = true
    
    navigationItem.searchController = searchController
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.title = "Search"
    navigationItem.hidesSearchBarWhenScrolling = false
    
    configureCollectionView()
    configureDataSource()
    
    bindViewModel()
    bindUI()
  }
  
  private func bindViewModel() {
    collectionView.rx.itemSelected
      .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] indexPath in
        self.collectionView.deselectItem(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .map { [unowned self] indexPath in
        let selectedToken = self.currentSnapshot
          .sectionIdentifiers[indexPath.section]
          .tokens[indexPath.row]
          .tokenText
        return selectedToken
      }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: viewModel.selectedToken)
      .disposed(by: disposeBag)
  }
  
  private func bindUI() {
    viewModel.suggestedSearchesList
      .drive(onNext: { [weak self] collection in
        self?.updateSnapshot(collection)
      })
      .disposed(by: disposeBag)
    
    viewModel.insertToken
      .drive(onNext: { [weak self] token in
        guard let self = self else { return }
        self.searchController.isActive = true
        self.searchController.searchBar.searchTextField.insertToken(token, at: 0)
      })
      .disposed(by: disposeBag)
  }
}

  // MARK: - Layouts
extension SearchMainViewController {
  
  func createLayout() -> UICollectionViewLayout {
    
    let sectionProvider = { [weak self] (sectionIndex: Int,
      layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
      guard let self = self else { return nil }
      
      return self.createPlainSection(layoutEnvironment: layoutEnvironment)
    }
    
    let config = UICollectionViewCompositionalLayoutConfiguration()
    
    let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider,
                                                     configuration: config)
    
    return layout
  }
  
  func createPlainSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    var groupFractionHeigh: CGFloat! = nil
    
    switch (layoutEnvironment.traitCollection.horizontalSizeClass, layoutEnvironment.traitCollection.verticalSizeClass) {
    case (.compact, .regular):
      groupFractionHeigh = CGFloat(0.06)
      
    case (.compact, .compact):
      groupFractionHeigh = CGFloat(0.1)
      
    case (.regular, .compact):
      groupFractionHeigh = CGFloat(0.06)
      
    case (.regular, .regular):
      groupFractionHeigh = CGFloat(0.06)
      
    default:
      groupFractionHeigh = CGFloat(0.06)
    }
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalHeight(groupFractionHeigh))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                   subitems: [item])
    
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
    
    return section
  }
}

  // MARK: - Setup Collection View
extension SearchMainViewController {
  
  func configureCollectionView() {
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .systemGroupedBackground
    collectionView.alwaysBounceVertical = true
    collectionView.keyboardDismissMode = .onDrag
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    view.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      
    ])
    
    collectionView.register(SearchSuggestionCollectionViewCell.self,
                            forCellWithReuseIdentifier: SearchSuggestionCollectionViewCell.reuseIdentifier)
  }
  
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource
      <SuggestedSearchCategoryData, SuggestedSearchCellData> (collectionView: collectionView) { [weak self] (collectionView: UICollectionView,
        indexPath: IndexPath,
        cellData: SuggestedSearchCellData) -> UICollectionViewCell? in
        
        guard let self = self else {
          return nil
        }
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchSuggestionCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? SearchSuggestionCollectionViewCell else {
                                                              fatalError("Can't create new cell")
        }
        
        cell.titleLabel.text = cellData.tokenText
        
        self.updateBorder(for: cell, at: indexPath)
        
        return cell
        
    }
  }
  
  private func updateBorder(for cell: SearchSuggestionCollectionViewCell, at indexPath: IndexPath) {
    if indexPath.row == self.currentSnapshot.numberOfItems - 1 {
      cell.separatorView.isHidden = true
    }
  }
}

// MARK: - Update Snapshot
extension SearchMainViewController {
  
  func updateSnapshot(_ collection: SuggestedSearchCategoryData) {
    currentSnapshot = NSDiffableDataSourceSnapshot
      <SuggestedSearchCategoryData, SuggestedSearchCellData>()
    
    currentSnapshot.appendSections([collection])
    currentSnapshot.appendItems(collection.tokens)
    
    dataSource.apply(currentSnapshot, animatingDifferences: true)
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
  
}

  // MARK: - UISearchResultsUpdating
extension SearchMainViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    guard let resultsController = searchController.searchResultsController as? SearchResultsViewController else {
        return
    }
    
    if !viewModel.replacedTokens(searchController.searchBar.searchTextField) {
      let text = searchController.searchBar.searchTextField.text
      let tokens = searchController.searchBar.searchTextField.tokens
      resultsController.viewModel.searchAtrr.accept((text, tokens))
    }
  }
}
