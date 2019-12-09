//
//  HomeDetailViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 22.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class HomeDetailViewController: UIViewController {
    
    let section: ShopCategoryData
    lazy var sectionByDates: ShopCategoryData = ShopCategoryData(name: section.name, shops: section.shops.shuffled())
    
    var editedCells: Set<ShopData> = []
    
    var needUpdateFavorites: Bool = false
    var needUpdateVisibleItems: Bool = false
    var sortType: Int = 0
    var textFilter: String = ""
    
    var favoritesUpdater: FavoritesUpdaterProtocol?
    
    let segmentedCell: ShopData = ShopData(name: "segmented", shortDescription: "segmented", websiteLink: "")
    let segmentedSection: ShopCategoryData = ShopCategoryData(name: "segmented")
    
    let searchCell: ShopData = ShopData(name: "search", shortDescription: "search", websiteLink: "")
    let searchSection: ShopCategoryData = ShopCategoryData(name: "search")
    
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource
        <ShopCategoryData, ShopData>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot
        <ShopCategoryData, ShopData>! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedSection.shops.append(segmentedCell)
        searchSection.shops.append(searchCell)
        
        configureCollectionView()
        configureDataSource()
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoritesDidChange), name: .didUpdateFavorites, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = section.name
        
        //NotificationCenter.default.addObserver(self, selector: #selector(updateSnapshot), name: .didUpdateFavorites, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if needUpdateVisibleItems {
            needUpdateVisibleItems = false
            updateVisibleItems()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
//        NotificationCenter.default.removeObserver(self, name: .didUpdateFavorites, object: nil)
        
        if !editedCells.isEmpty || needUpdateFavorites {
            favoritesUpdater?.updateFavoritesCollections(in: section.name, with: editedCells)
            //favoritesUpdater?.updateFavoritesCollections(in: section)
            editedCells.removeAll()
            needUpdateFavorites = false
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        if !editedCells.isEmpty || needUpdateFavorites {
//            favoritesUpdater?.updateFavoritesCollections(in: section.sectionTitle, with: editedCells)
//            //favoritesUpdater?.updateFavoritesCollections(in: section)
//            editedCells.removeAll()
//            needUpdateFavorites = false
//        }
//    }
    
    init(section: ShopCategoryData) {
        self.section = section
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didUpdateFavorites, object: nil)
    }

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
        //config.interSectionSpacing = 20
        
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
            groupFractionHeigh = CGFloat(0.35)
            
        case (.regular, .regular):
            groupFractionHeigh = CGFloat(0.25)
            
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
                    
                    cell.counLabel.text = "\(self.section.shops.count) shops"
                    cell.segmentedControl.selectedSegmentIndex = self.sortType
                    cell.segmentedControl.addTarget(self, action: #selector(FavoritesViewController.selectedSegmentDidChange(_:)), for: .valueChanged)
                    
                    return cell
                    
                default:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeDetailCollectionViewCell.reuseIdentifier,
                                                                        for: indexPath) as? HomeDetailCollectionViewCell else {
                        fatalError("Can't create new cell")
                    }
                    
                    if let image = cellData.image {
                        cell.imageView.image = image
                    }
                    cell.titleLabel.text = cellData.name
                    cell.subtitleLabel.text = cellData.shortDescription
                    cell.addToFavoritesButton.checkbox.isHighlighted = cellData.isFavorite
                    
                    //cell.addToFavoritesButton.cellIndex = indexPath
                    cell.addToFavoritesButton.cell = cellData
                    cell.addToFavoritesButton.addTarget(self, action: #selector(HomeDetailViewController.addToFavorites(_:)), for: .touchUpInside)
                    
                    if indexPath.row == self.section.shops.count - 1 {
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
        
        currentSnapshot.appendSections([section])
        currentSnapshot.appendItems(section.shops)
        
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}

    // MARK: - Interaction
extension HomeDetailViewController {
    
    // Add to Favorites
    @objc func addToFavorites(_ sender: AddToFavoritesButton) {
        
        guard let cell = sender.cell else { return }
        
        cell.isFavorite = !cell.isFavorite
        
        //sender.checkbox.isHighlighted = cell.isFavorite
        UIView.animate(withDuration: 0.15) {
            sender.checkbox.isHighlighted = cell.isFavorite
        }
        
        if cell.isFavorite {
            cell.favoriteAddingDate = Date(timeIntervalSinceNow: 0)
            editedCells.insert(cell)
        } else {
            cell.favoriteAddingDate = nil
            if editedCells.remove(cell) == nil {
                needUpdateFavorites = true
            }
        }
    }
    
    @objc func favoritesDidChange() {
        needUpdateVisibleItems = true
    }
    
    @objc func selectedSegmentDidChange(_ segmentedControl: UISegmentedControl) {
        sortType = segmentedControl.selectedSegmentIndex
        
        if !textFilter.isEmpty {
            performQuery(with: textFilter)
        } else {
            updateSnapshot()
        }
    }
    
    func updateSnapshot() {
        
        currentSnapshot = NSDiffableDataSourceSnapshot
            <ShopCategoryData, ShopData>()
        
        currentSnapshot.appendSections([searchSection])
        currentSnapshot.appendItems(searchSection.shops)
        
        currentSnapshot.appendSections([segmentedSection])
        currentSnapshot.appendItems(segmentedSection.shops)
        
        switch sortType {
        case 0:
            currentSnapshot.appendSections([section])
            currentSnapshot.appendItems(section.shops)
        default:
            currentSnapshot.appendSections([sectionByDates])
            currentSnapshot.appendItems(sectionByDates.shops)
        }
        
        dataSource.apply(currentSnapshot, animatingDifferences: true)
        
    }
    
    func updateVisibleItems() {
        
        let indexPaths = collectionView.indexPathsForVisibleItems
        
        /// This code is crashing
//        let items = indexPaths.reduce(into: [ShopData]()) { result, index in
//            guard let cell = dataSource.itemIdentifier(for: index) else { return }
//            result.append(cell)
//        }
        
//        currentSnapshot.reloadItems(items)
//        dataSource.apply(currentSnapshot, animatingDifferences: true)
        
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
    
    func performQuery(with filter: String) {
        currentSnapshot = NSDiffableDataSourceSnapshot
        <ShopCategoryData, ShopData>()
        
        currentSnapshot.appendSections([searchSection])
        currentSnapshot.appendItems(searchSection.shops)

        currentSnapshot.appendSections([segmentedSection])
        currentSnapshot.appendItems(segmentedSection.shops)
        

        let filtered = filteredCollection(with: filter)
        let section = ShopCategoryData(name: self.section.name, shops: filtered)
        currentSnapshot.appendSections([section])
        currentSnapshot.appendItems(section.shops)
        
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    func filteredCollection(with filter: String) -> [ShopData] {
        
        let shops: [ShopData]
        switch sortType {
        case 0:
            shops = section.shops
        default:
            shops = sectionByDates.shops
        }
        
        if filter.isEmpty {
            return shops
        }
        let lowercasedFilter = filter.lowercased()
        
        let filtered = shops.filter { cell in
                return cell.name.lowercased().contains(lowercasedFilter)
        }
        
        return filtered.sorted { $0.name < $1.name }
    }
}

    // MARK: - SerachBarDelegate

extension HomeDetailViewController: UISearchBarDelegate, UITextFieldDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        textFilter = searchText
        if searchText.isEmpty {
            updateSnapshot()
        } else {
            performQuery(with: searchText)
        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedShop = currentSnapshot.sectionIdentifiers[indexPath.section].shops[indexPath.row]
        
        let viewController = ShopViewController(shop: selectedShop)
        let navController = UINavigationController(rootViewController: viewController)
        //navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
        
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
