//
//  HomeDetailViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 22.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeDetailViewController: UIViewController {
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private var viewModel: HomeDetailViewModel!
//  private var navigator: Navigator!
  
//  let section: ShopCategoryData!
//  lazy var sectionByDates: ShopCategoryData = ShopCategoryData(categoryName: section.categoryName, shops: section.shops.shuffled())
  
//  var addedInFavorites: Set<ShopData> = []
//  var deletedFromFavorites: Set<ShopData> = []
  
//  private var needUpdateVisibleItems: Bool = false
//  var sortType: Int = 0
//  var textFilter: String = ""
  
//  var favoritesUpdater: FavoritesUpdaterProtocol?
  
  private let segmentedCell: ShopData = ShopData(name: "segmented", shortDescription: "segmented", websiteLink: "")
  private let segmentedSection: ShopCategoryData = ShopCategoryData(categoryName: "segmented")
  
  private let searchCell: ShopData = ShopData(name: "search", shortDescription: "search", websiteLink: "")
  private let searchSection: ShopCategoryData = ShopCategoryData(categoryName: "search")
  
  var collectionView: UICollectionView! = nil
  var dataSource: UICollectionViewDiffableDataSource
    <ShopCategoryData, ShopData>! = nil
  var currentSnapshot: NSDiffableDataSourceSnapshot
    <ShopCategoryData, ShopData>! = nil
  
  static func createWith(viewModel: HomeDetailViewModel) -> HomeDetailViewController {
    let vc = HomeDetailViewController()
    vc.viewModel = viewModel
    
    return vc
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    segmentedSection.shops.append(segmentedCell)
    searchSection.shops.append(searchCell)
    
    configureCollectionView()
    configureDataSource()
    
    bindViewModel()
    bindUI()
    
//    NotificationCenter.default.addObserver(self, selector: #selector(HomeDetailViewController.favoritesDidChange), name: .didUpdateFavorites, object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.prefersLargeTitles = true
    
    viewModel.currentSection
      .asObservable()
      .take(1)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] section in
        self?.navigationItem.title = section.categoryName
      })
      .disposed(by: disposeBag)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
//    if needUpdateVisibleItems {
//      needUpdateVisibleItems = false
//      updateVisibleItems()
//    }
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    viewModel.controllerWillDisappear.accept(())
    
//    if !addedInFavorites.isEmpty || !deletedFromFavorites.isEmpty {
//      favoritesUpdater?.updateFavoritesCollections(in: section.categoryName,
//                                                   added: addedInFavorites,
//                                                   deleted: deletedFromFavorites)
//      DispatchQueue.global(qos: .utility).async { [weak self] in
//        guard let self = self else { return }
//        let cache = CacheController()
//        let shops = self.section.shops
//        shops.forEach {
//          cache.shop(with: $0.name, isFavorite: $0.isFavorite, date: $0.favoriteAddingDate)
//        }
//      }
//      addedInFavorites.removeAll()
//      deletedFromFavorites.removeAll()
//    }
  }
  
  private func bindUI() {
    viewModel.currentSection
      .drive(onNext: { [weak self] section in
//        print("\n***\nupdateHomeaDetail\n***\n")
        self?.updateSnapshot(section)
      })
      .disposed(by: disposeBag)
    
  }
  
  private func bindViewModel() {
    
//    let collectionViewItem = collectionView.rx.itemSelected.share()
    collectionView.rx.itemSelected
//    collectionViewItem
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] indexPath in
        self.collectionView.deselectItem(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected
//    collectionViewItem
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .map { _ in () }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: viewModel.controllerWillDisappear)
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected
//    collectionViewItem
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
  
//  init() {
//    super.init(nibName: nil, bundle: nil)
//  }
//
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//  deinit {
//    NotificationCenter.default.removeObserver(self, name: .didUpdateFavorites, object: nil)
//  }
  
}

// MARK: - Layouts
extension HomeDetailViewController {
  
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
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
    
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
    
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
    
    var groupFractionHeigh: CGFloat! = nil
    
    switch (layoutEnvironment.traitCollection.horizontalSizeClass, layoutEnvironment.traitCollection.verticalSizeClass) {
    case (.compact, .regular):
      groupFractionHeigh = CGFloat(0.15)
      
    case (.compact, .compact):
      groupFractionHeigh = CGFloat(0.3)
      
    case (.regular, .compact):
      groupFractionHeigh = CGFloat(0.15)
      
    case (.regular, .regular):
      groupFractionHeigh = CGFloat(0.15)
      
    default:
      groupFractionHeigh = CGFloat(0.15)
    }
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalHeight(groupFractionHeigh))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                   subitems: [item])
    
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
    
    return section
  }
}

// MARK: - Setup Collection View
extension HomeDetailViewController {
  
  func configureCollectionView() {
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .systemBackground
    collectionView.alwaysBounceVertical = true
    collectionView.keyboardDismissMode = .onDrag
    view.addSubview(collectionView)
    
    collectionView.delegate = self
    
    NSLayoutConstraint.activate([
      
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      
    ])
    
    
    collectionView.register(HomeDetailCollectionViewCell.self,
                            forCellWithReuseIdentifier: HomeDetailCollectionViewCell.reuseIdentifier)
    
    collectionView.register(HomeDetailSegmentedControlCollectionViewCell.self,
                            forCellWithReuseIdentifier: HomeDetailSegmentedControlCollectionViewCell.reuseIdentifier)
    
    collectionView.register(SearchCollectionViewCell.self,
                            forCellWithReuseIdentifier: SearchCollectionViewCell.reuseIdentidier)
  }
  
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource
      <ShopCategoryData, ShopData> (collectionView: collectionView) { [weak self] (collectionView: UICollectionView,
        indexPath: IndexPath,
        cellData: ShopData) -> UICollectionViewCell? in
        guard let self = self else {
          return nil
        }
        
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
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:        HomeDetailSegmentedControlCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as? HomeDetailSegmentedControlCollectionViewCell else {
                                                                fatalError("Can't create new cell")
          }
          
//          cell.countLabel.text = "\(self.section.shops.count) shops"
          self.viewModel.currentSection
            .map { section in
              return "\(section.shops.count) shops"
          }
          .drive(cell.countLabel.rx.text)
          .disposed(by: cell.disposeBag)
          
          cell.segmentedControl.selectedSegmentIndex = self.viewModel.segmentIndex.value
          
//          cell.segmentedControl.rx.selectedSegmentIndex
            cell.segmentedControl.rx.controlEvent(.valueChanged)
            .throttle(RxTimeInterval.milliseconds(500),
                      scheduler: MainScheduler.instance)
//            .distinctUntilChanged()
            .map { cell.segmentedControl.selectedSegmentIndex }
            .subscribeOn(self.eventScheduler)
            .observeOn(self.eventScheduler)
            .bind(to: self.viewModel.segmentIndex)
            .disposed(by: cell.disposeBag)
//          cell.segmentedControl.addTarget(self, action: #selector(FavoritesViewController.selectedSegmentDidChange(_:)), for: .valueChanged)
          
          return cell
          
        default:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeDetailCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as? HomeDetailCollectionViewCell else {
                                                                fatalError("Can't create new cell")
          }
          
          if let image = cellData.previewImage {
            cell.imageView.image = image
          } else {
            cell.imageView.backgroundColor = cellData.placeholderColor
//            self.setupImage(at: indexPath, with: cellData)
            self.viewModel.setupImage(for: cellData)
              .observeOn(MainScheduler.instance)
              .subscribe(onCompleted: {
                cell.imageView.image = cellData.previewImage
              })
              .disposed(by: cell.disposeBag)
          }
          cell.titleLabel.text = cellData.name
          cell.subtitleLabel.text = cellData.shortDescription
          cell.addToFavoritesButton.checkbox.isHighlighted = cellData.isFavorite
          cell.addToFavoritesButton.cell = cellData
          
//          cell.addToFavoritesButton.addTarget(self, action: #selector(HomeDetailViewController.addToFavorites(_:)), for: .touchUpInside)
          
          cell.addToFavoritesButton.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
              self.viewModel.updateFavorites(cell.addToFavoritesButton)
              UIView.animate(withDuration: 0.15) {
                cell.addToFavoritesButton.checkbox.isHighlighted = cellData.isFavorite
              }
            })
            .disposed(by: cell.disposeBag)
          
          cell.addToFavoritesButton.rx.tap
            .map { cellData }
            .throttle(RxTimeInterval.milliseconds(500),
                      scheduler: MainScheduler.instance)
            .subscribeOn(self.eventScheduler)
            .observeOn(self.eventScheduler)
            .bind(to: self.viewModel.editedShops)
            .disposed(by: cell.disposeBag)
          
//          if indexPath.row == self.section.shops.count - 1 {
          if indexPath.row == self.currentSnapshot.numberOfItems - 3 {
            cell.separatorView.isHidden = true
          }
          
          return cell
        }
        
    }
    
    currentSnapshot = NSDiffableDataSourceSnapshot
      <ShopCategoryData, ShopData>()
    
    currentSnapshot.appendSections([searchSection])
    currentSnapshot.appendItems(searchSection.shops)
    
    currentSnapshot.appendSections([segmentedSection])
    currentSnapshot.appendItems(segmentedSection.shops)
    
//    currentSnapshot.appendSections([section])
//    currentSnapshot.appendItems(section.shops)
    
    dataSource.apply(currentSnapshot, animatingDifferences: false)
  }
}

  // MARK: - Interaction
extension HomeDetailViewController {
  
  // Add to Favorites
//  @objc func addToFavorites(_ sender: AddToFavoritesButton) {
//    guard let cell = sender.cell else { return }
//
//    cell.isFavorite = !cell.isFavorite
//
//    UIView.animate(withDuration: 0.15) {
//      sender.checkbox.isHighlighted = cell.isFavorite
//    }
//
//    if cell.isFavorite {
//      cell.favoriteAddingDate = Date(timeIntervalSinceNow: 0)
//
//      addedInFavorites.insert(cell)
//      deletedFromFavorites.remove(cell)
//
//    } else {
//      cell.favoriteAddingDate = nil
//
//      deletedFromFavorites.insert(cell)
//      addedInFavorites.remove(cell)
//    }
//  }
//
//  @objc func favoritesDidChange() {
//    needUpdateVisibleItems = true
//  }
  
//  @objc func selectedSegmentDidChange(_ segmentedControl: UISegmentedControl) {
//    sortType = segmentedControl.selectedSegmentIndex
//
//    if !textFilter.isEmpty {
//      performQuery(with: textFilter)
//    } else {
//      updateSnapshot()
//    }
//  }
  
  func updateSnapshot(_ section: ShopCategoryData) {
    
    currentSnapshot = NSDiffableDataSourceSnapshot
      <ShopCategoryData, ShopData>()
    
    currentSnapshot.appendSections([searchSection])
    currentSnapshot.appendItems(searchSection.shops)
    
    currentSnapshot.appendSections([segmentedSection])
    currentSnapshot.appendItems(segmentedSection.shops)
    
//    switch sortType {
//    case 0:
      currentSnapshot.appendSections([section])
      currentSnapshot.appendItems(section.shops)
//    default:
//      currentSnapshot.appendSections([sectionByDates])
//      currentSnapshot.appendItems(sectionByDates.shops)
//    }
    
    dataSource.apply(currentSnapshot, animatingDifferences: true)
    
  }
  
  func updateVisibleItems() {
    let indexPaths = collectionView.indexPathsForVisibleItems
    
    indexPaths.forEach { indexPath in
      guard let cell = collectionView.cellForItem(at: indexPath) as? HomeDetailCollectionViewCell,
        let cellData = dataSource.itemIdentifier(for: indexPath) else {
          return
      }
      
      UIView.animate(withDuration: 0.3) {
        cell.addToFavoritesButton.checkbox.isHighlighted = cellData.isFavorite
      }
    }
  }
}

// MARK: - Search
extension HomeDetailViewController {
  
//  func performQuery(with filter: String) {
//    currentSnapshot = NSDiffableDataSourceSnapshot
//      <ShopCategoryData, ShopData>()
//
//    currentSnapshot.appendSections([searchSection])
//    currentSnapshot.appendItems(searchSection.shops)
//
//    currentSnapshot.appendSections([segmentedSection])
//    currentSnapshot.appendItems(segmentedSection.shops)
//
//
//    let filtered = filteredCollection(with: filter)
//    let section = ShopCategoryData(categoryName: self.section.categoryName, shops: filtered)
//    currentSnapshot.appendSections([section])
//    currentSnapshot.appendItems(section.shops)
//
//    dataSource.apply(currentSnapshot, animatingDifferences: true)
//  }
  
//  func filteredCollection(with filter: String) -> [ShopData] {
//
//    let shops: [ShopData]
//    switch sortType {
//    case 0:
//      shops = section.shops
//    default:
//      shops = sectionByDates.shops
//    }
//
//    if filter.isEmpty {
//      return shops
//    }
//    let lowercasedFilter = filter.lowercased()
//
//    let filtered = shops.filter { cell in
//      return cell.name.lowercased().contains(lowercasedFilter)
//    }
//
//    return filtered.sorted { $0.name < $1.name }
//  }
}

// MARK: - SerachBarDelegate
extension HomeDetailViewController: UISearchBarDelegate, UITextFieldDelegate {
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.searchText.accept(searchText)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}

// MARK: - UICollectionViewDelegate
extension HomeDetailViewController: UICollectionViewDelegate {
  
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
  
//  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    let selectedShop = currentSnapshot.sectionIdentifiers[indexPath.section].shops[indexPath.row]
//
//    if let _ = addedInFavorites.remove(selectedShop) {
//      ModelController.insertInFavorites(shop: selectedShop)
//    } else if let _ = deletedFromFavorites.remove(selectedShop) {
//      ModelController.deleteFromFavorites(shop: selectedShop)
//    }
//
//    let viewController = ShopViewController(shop: selectedShop)
//    viewController.previousViewUpdater = self
//    let navController = UINavigationController(rootViewController: viewController)
//    present(navController, animated: true)
//
//    collectionView.deselectItem(at: indexPath, animated: true)
//  }
}

//extension HomeDetailViewController: ScreenUpdaterProtocol {
//
//  func updateScreen() {
//    if needUpdateVisibleItems {
//      //needUpdateFavorites = true
//      needUpdateVisibleItems = false
//      updateVisibleItems()
//    }
//  }
//}

//MARK: - Setup Image
extension HomeDetailViewController {
  
//  private func setupImage(at indexPath: IndexPath, with cellData: ShopData) {
//    NetworkController.setupPreviewImage(in: cellData) {
//      DispatchQueue.main.async { [weak self] in
//        if let cell = self?.collectionView.cellForItem(at: indexPath) as? CellWithImage {
//          cell.imageView.image = cellData.previewImage
//        }
//      }
//    }
//  }
}
