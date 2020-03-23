//
//  FavoritesViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 28.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FavoritesViewController: UIViewController {
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private let viewModel = FavoritesViewModel()
  
  static let titleElementKind = "title-element-kind"
  
  private let segmentedCell: ShopData = ShopData(name: "segmented", shortDescription: "segmented")
  private let segmentedSection: ShopCategoryData = ShopCategoryData(categoryName: "segmented")
  
  private let searchCell: ShopData = ShopData(name: "search", shortDescription: "search")
  private let searchSection: ShopCategoryData = ShopCategoryData(categoryName: "search")
  
  var collectionView: UICollectionView! = nil
  var dataSource: UICollectionViewDiffableDataSource
    <ShopCategoryData, ShopData>! = nil
  
  var currentSnapshot: NSDiffableDataSourceSnapshot
    <ShopCategoryData, ShopData>! = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Favorites"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.tintColor = UIColor(named: "BlueTintColor")
    
    segmentedSection.shops.append(segmentedCell)
    searchSection.shops.append(searchCell)
    
    configureCollectionView()
    configureDataSource()
    
//    let refresh = UIRefreshControl()
//    collectionView?.refreshControl = refresh
    
    bindViewModel()
    bindUI()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    viewModel.commitChanges.accept(())
  }
  
  private func bindViewModel() {
    if let refresh = collectionView.refreshControl {
      refresh.rx.controlEvent(.valueChanged)
        .map { _ in refresh.isRefreshing }
        .subscribeOn(eventScheduler)
        .observeOn(eventScheduler)
        .bind(to: viewModel.refresh)
        .disposed(by: disposeBag)
    }
    
    collectionView.rx.itemSelected
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] indexPath in
        self.collectionView.deselectItem(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .map { [unowned self] indexPath in
        let selectedShop = self.currentSnapshot.sectionIdentifiers[indexPath.section].shops[indexPath.row]
        return (self, selectedShop)
      }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: viewModel.showShopVC)
      .disposed(by: disposeBag)
  }
  
  private func bindUI() {
    if let refresh = collectionView.refreshControl {
      viewModel.isRefreshing
        .drive(refresh.rx.isRefreshing)
        .disposed(by: disposeBag)
    }
    
    viewModel.currentSection
      .drive(onNext: { [weak self] section in
        self?.updateSnapshot(section)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Layouts
extension FavoritesViewController {
  
  func createLayout() -> UICollectionViewLayout {
    
    let sectionProvider = { [weak self] (sectionIndex: Int,
      layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
      
      guard let self = self else { return nil }
      switch sectionIndex {
      case 0:
        return self.createSearchSection(layoutEnvironment)
        
      case 1:
        return self.createSegmentedControlSection(layoutEnvironment)
        
      default:
        return self.createPlainSection(layoutEnvironment)
      }
    }
    
    let config = UICollectionViewCompositionalLayoutConfiguration()
    
    let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider,
                                                     configuration: config)
    
    return layout
  }
  
  func createSearchSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(56))
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    
    section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
    
    return section
  }
  
  func createSegmentedControlSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    
    section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 30, trailing: 10)
    
    return section
  }
  
  func createPlainSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    var groupFractionHeigh: CGFloat! = nil
    
    switch (layoutEnvironment.traitCollection.horizontalSizeClass, layoutEnvironment.traitCollection.verticalSizeClass) {
    case (.compact, .regular):
      groupFractionHeigh = CGFloat(0.2)
      
    case (.compact, .compact):
      groupFractionHeigh = CGFloat(0.35)
      
    case (.regular, .compact):
      groupFractionHeigh = CGFloat(0.35)
      
    case (.regular, .regular):
      groupFractionHeigh = CGFloat(0.2)
      
    default:
      groupFractionHeigh = CGFloat(0.2)
    }
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalHeight(groupFractionHeigh))
    
    let columns = layoutEnvironment.container.effectiveContentSize.width > 700 ? 4 : 2
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
    group.interItemSpacing = .fixed(10)
    
    let section = NSCollectionLayoutSection(group: group)
    
    section.interGroupSpacing = 10
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 30, trailing: 10)
    
    let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .estimated(60))
    
    let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize,
                                                                         elementKind: FavoritesViewController.titleElementKind,
                                                                         alignment: .top)
    
    section.boundarySupplementaryItems = [titleSupplementary]
    
    return section
  }
}

// MARK: - Setup Collection View
extension FavoritesViewController {
  
  func configureCollectionView() {
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .systemBackground
    collectionView.keyboardDismissMode = .onDrag
    collectionView.alwaysBounceVertical = true
    collectionView.showsVerticalScrollIndicator = false
    view.addSubview(collectionView)
    
    collectionView.delegate = self
    
    NSLayoutConstraint.activate([
      
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      
    ])
    
    collectionView.register(SearchCollectionViewCell.self,
                            forCellWithReuseIdentifier: SearchCollectionViewCell.reuseIdentidier)
    
    collectionView.register(FavoritesSegmentedControlCollectionViewCell.self,
                            forCellWithReuseIdentifier: FavoritesSegmentedControlCollectionViewCell.reuseIdentifier)
    
    collectionView.register(FavoritesPlainCollectionViewCell.self,
                            forCellWithReuseIdentifier: FavoritesPlainCollectionViewCell.reuseIdentifier)
    
    collectionView.register(TitleSupplementaryView.self,
                            forSupplementaryViewOfKind: FavoritesViewController.titleElementKind,
                            withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
  }
  
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource
      <ShopCategoryData, ShopData> (collectionView: collectionView) { [weak self] (collectionView: UICollectionView,
        indexPath: IndexPath,
        cellData: ShopData) -> UICollectionViewCell? in
        
        guard let self = self else { return nil }
        
        switch indexPath.section {
        case 0:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.reuseIdentidier,
                                                              for: indexPath) as? SearchCollectionViewCell else {
                                                                fatalError("Can't create new cell")
          }
          cell.searchBar.delegate = self
          cell.searchBar.searchTextField.delegate = self
          
          return cell
          
        case 1:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritesSegmentedControlCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as? FavoritesSegmentedControlCollectionViewCell else {
                                                                fatalError("Can't create new cell")
          }
          
          cell.segmentedControl.selectedSegmentIndex = self.viewModel.segmentIndex.value
            cell.segmentedControl.rx.controlEvent(.valueChanged)
            .throttle(RxTimeInterval.milliseconds(500),
                      scheduler: MainScheduler.instance)
            .map { cell.segmentedControl.selectedSegmentIndex }
            .subscribeOn(self.eventScheduler)
            .observeOn(self.eventScheduler)
            .bind(to: self.viewModel.segmentIndex)
            .disposed(by: cell.disposeBag)
          
          return cell
          
        default:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritesPlainCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as? FavoritesPlainCollectionViewCell else {
                                                                fatalError("Can't create new cell")
          }
          
          if let image = cellData.previewImage {
            cell.imageView.image = image
          } else {
            cell.imageView.backgroundColor = cellData.placeholderColor
            self.viewModel.setupImage(for: cellData)
              .observeOn(MainScheduler.instance)
              .subscribe(onCompleted: {
                cell.imageView.image = cellData.previewImage
              })
              .disposed(by: cell.disposeBag)
          }
          
          cell.titleLabel.text = cellData.name
          cell.subtitleLabel.text = cellData.shortDescription
          cell.favoritesButton.checkbox.isHighlighted = cellData.isFavorite
          cell.favoritesButton.cell = cellData
          
          cell.favoritesButton.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
              self.viewModel.updateFavorites(cell.favoritesButton)
              UIView.animate(withDuration: 0.15) {
                cell.favoritesButton.checkbox.isHighlighted = cellData.isFavorite
              }
            })
            .disposed(by: cell.disposeBag)
          
          cell.favoritesButton.rx.tap
            .map { cellData }
            .throttle(RxTimeInterval.milliseconds(500),
                      scheduler: MainScheduler.instance)
            .subscribeOn(self.eventScheduler)
            .observeOn(self.eventScheduler)
            .bind(to: self.viewModel.editedShops)
            .disposed(by: cell.disposeBag)
          
          return cell
        }
        
    }
    
    dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
      
      guard let self = self,
        let snapshot = self.currentSnapshot else {
          return nil
      }
      
      if let titleSupplementary = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                  withReuseIdentifier: TitleSupplementaryView.reuseIdentifier,
                                                                                  for: indexPath) as? TitleSupplementaryView {
        let section = snapshot.sectionIdentifiers[indexPath.section]
        titleSupplementary.label.text = section.categoryName
        
        return titleSupplementary
      } else {
        fatalError("Can't create new supplementary")
      }
      
    }
    
    currentSnapshot = NSDiffableDataSourceSnapshot
      <ShopCategoryData, ShopData>()
    
    currentSnapshot.appendSections([searchSection])
    currentSnapshot.appendItems(searchSection.shops)
    
    currentSnapshot.appendSections([segmentedSection])
    currentSnapshot.appendItems(segmentedSection.shops)
    
    dataSource.apply(currentSnapshot, animatingDifferences: false)
  }
}

// MARK: - Updating snapshot
extension FavoritesViewController {
  
  func updateSnapshot(_ section: [ShopCategoryData]) {
    currentSnapshot = NSDiffableDataSourceSnapshot
      <ShopCategoryData, ShopData>()
    
    currentSnapshot.appendSections([searchSection])
    currentSnapshot.appendItems(searchSection.shops)
    
    currentSnapshot.appendSections([segmentedSection])
    currentSnapshot.appendItems(segmentedSection.shops)
    
    section.forEach { section in
      currentSnapshot.appendSections([section])
      currentSnapshot.appendItems(section.shops)
    }
    
    dataSource.apply(currentSnapshot, animatingDifferences: true)
  }
}

// MARK: - Actions
extension FavoritesViewController {
  func updateVisibleItems() {
    let indexPaths = collectionView.indexPathsForVisibleItems
    
    indexPaths.forEach { indexPath in
      guard let cell = collectionView.cellForItem(at: indexPath) as? FavoritesPlainCollectionViewCell else {
        return
      }
      
      UIView.animate(withDuration: 0.3) {
        cell.favoritesButton.checkbox.isHighlighted = true
      }
    }
  }
}

  // MARK: - SerachBarDelegate
extension FavoritesViewController: UISearchBarDelegate, UITextFieldDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.searchText.accept(searchText)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}

  // MARK: - UICollectionViewDelegate
extension FavoritesViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    switch indexPath.section {
    case 0:
      return false
    case 1:
      return false
    default:
      return true
    }
  }
}

