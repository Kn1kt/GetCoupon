//
//  FavoritesViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 28.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    let favoritesDataController = ModelController.favoritesDataController
    var sortType: Int = 0
    static let titleElementKind = "title-element-kind"
    
    var needUpdateDataSource: Bool = false
    var needUpdateSnapshot: Bool = false
    var textFilter: String = ""
    
    var closeKeyboardGesture: UITapGestureRecognizer?
    
    let segmentedCell: ShopData = ShopData(name: "segmented", shortDescription: "segmented")
    let segmentedSection: ShopCategoryData = ShopCategoryData(categoryName: "segmented")
    
    let searchCell: ShopData = ShopData(name: "search", shortDescription: "search")
    let searchSection: ShopCategoryData = ShopCategoryData(categoryName: "search")
    
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
        
        favoritesDataController.snapshotUpdater = self
        configureCollectionView()
        configureDataSource()
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(FavoritesViewController.refresh), for: UIControl.Event.valueChanged)
        collectionView?.refreshControl = refresh
//        collectionView.refreshControl?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(FavoritesViewController.addGestureRecognizer), name: UIResponder.keyboardWillShowNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(FavoritesViewController.deleteGestureRecognizer), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if needUpdateSnapshot {
            needUpdateSnapshot = false
            
            if !textFilter.isEmpty {
                performQuery(with: textFilter)
            } else {
                updateSnapshot()
            }
            
            collectionView.indexPathsForVisibleItems.forEach { indexPath in
                guard let cell = collectionView.cellForItem(at: indexPath) as? FavoritesPlainCollectionViewCell else {
                    return
                }
                cell.favoritesButton.checkbox.isHighlighted = true
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if needUpdateDataSource {
            needUpdateDataSource = false
            favoritesDataController.checkCollection()
        }

        //NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        //NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        if needUpdateDataSource {
//            needUpdateDataSource = false
//            favoritesDataController.checkCollection()
//        }
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
                                               heightDimension: .estimated(44))
        
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
        
        // No need delegete for this step
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
                    
                    cell.segmentedControl.selectedSegmentIndex = self.sortType
                    cell.segmentedControl.addTarget(self, action: #selector(FavoritesViewController.selectedSegmentDidChange(_:)), for: .valueChanged)
                    
                    return cell
                    
                default:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritesPlainCollectionViewCell.reuseIdentifier,
                                                                        for: indexPath) as? FavoritesPlainCollectionViewCell else {
                        fatalError("Can't create new cell")
                    }
                    
                    if let image = cellData.image {
                        cell.imageView.image = image
                    }
                    
                    cell.titleLabel.text = cellData.name
                    cell.subtitleLabel.text = cellData.shortDescription
                    cell.favoritesButton.checkbox.isHighlighted = cellData.isFavorite
                    //cell.favoritesButton.cellIndex = indexPath
                    cell.favoritesButton.cell = cellData
                    cell.favoritesButton.addTarget(self, action: #selector(FavoritesViewController.addToFavorites(_:)), for: .touchUpInside)
                    
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
        
        favoritesDataController.collectionsBySections.forEach { collection in
            currentSnapshot.appendSections([collection])
            currentSnapshot.appendItems(collection.shops)
        }
        
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}

    // MARK: - Updating snapshot
extension FavoritesViewController: SnapshotUpdaterProtocol {
    
    func updateSnapshot() {
        currentSnapshot = NSDiffableDataSourceSnapshot
        <ShopCategoryData, ShopData>()
        
        currentSnapshot.appendSections([searchSection])
        currentSnapshot.appendItems(searchSection.shops)

        currentSnapshot.appendSections([segmentedSection])
        currentSnapshot.appendItems(segmentedSection.shops)

        switch sortType {
        case 0:
            favoritesDataController.collectionsBySections.forEach { collection in
                currentSnapshot.appendSections([collection])
                currentSnapshot.appendItems(collection.shops)
            }
        default:
            let section = ShopCategoryData(categoryName: "", shops: favoritesDataController.collectionsByDates)
            currentSnapshot.appendSections([section])
            currentSnapshot.appendItems(section.shops)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dataSource.apply(self.currentSnapshot, animatingDifferences: true)
        }
        
        
    }
}

    // MARK: - Actions
extension FavoritesViewController {
    
    @objc func refresh() {
        
        if needUpdateDataSource {
            needUpdateDataSource = false
            favoritesDataController.checkCollection()
        }
        needUpdateSnapshot = false
        
        if !textFilter.isEmpty {
            performQuery(with: textFilter)
        } else {
            updateSnapshot()
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    @objc func selectedSegmentDidChange(_ segmentedControl: UISegmentedControl) {
        sortType = segmentedControl.selectedSegmentIndex
        
        if needUpdateDataSource {
            needUpdateDataSource = false
            favoritesDataController.checkCollection()
        }
        needUpdateSnapshot = false
        
        if !textFilter.isEmpty {
            performQuery(with: textFilter)
        } else {
            updateSnapshot()
        }
    }
}

extension FavoritesViewController {
    
    // Add to Favorites
    @objc func addToFavorites(_ sender: AddToFavoritesButton) {
        
        //guard let cellIndex = sender.cellIndex else { return }
        guard let cell = sender.cell else { return }
        
        cell.isFavorite = !cell.isFavorite
        
//        sender.checkbox.isHighlighted = cell.isFavorite
        UIView.animate(withDuration: 0.15) {
            sender.checkbox.isHighlighted = cell.isFavorite
        }
        
        if !cell.isFavorite {
            needUpdateDataSource = true
        }
    }
}

    // MARK: - Search

extension FavoritesViewController {
    
    func performQuery(with filter: String) {
        currentSnapshot = NSDiffableDataSourceSnapshot
        <ShopCategoryData, ShopData>()
        
        currentSnapshot.appendSections([searchSection])
        currentSnapshot.appendItems(searchSection.shops)

        currentSnapshot.appendSections([segmentedSection])
        currentSnapshot.appendItems(segmentedSection.shops)
        
        switch sortType {
        case 0:
            let filtered = favoritesDataController.filteredCollectionBySections(with: filter)
            filtered.forEach { collection in
                currentSnapshot.appendSections([collection])
                currentSnapshot.appendItems(collection.shops)
            }
        default:
            let filtered = favoritesDataController.filteredCollectionByDates(with: filter)
            let section = ShopCategoryData(categoryName: "", shops: filtered)
            currentSnapshot.appendSections([section])
            currentSnapshot.appendItems(section.shops)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dataSource.apply(self.currentSnapshot, animatingDifferences: true)
        }
        
    }
}

    // MARK: - SerachBarDelegate

extension FavoritesViewController: UISearchBarDelegate, UITextFieldDelegate {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedShop = currentSnapshot.sectionIdentifiers[indexPath.section].shops[indexPath.row]
        
        let viewController = ShopViewController(shop: selectedShop)
        viewController.previousViewUpdater = self
        let navController = UINavigationController(rootViewController: viewController)
        //navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if needUpdateDataSource {
            needUpdateDataSource = false
            favoritesDataController.checkCollection()
        }
        
        if needUpdateSnapshot {
            needUpdateSnapshot = false

            if !textFilter.isEmpty {
                performQuery(with: textFilter)
            } else {
                updateSnapshot()
            }

        
        
            collectionView.indexPathsForVisibleItems.forEach { indexPath in
                guard let cell = collectionView.cellForItem(at: indexPath) as? FavoritesPlainCollectionViewCell else {
                    return
                }
                cell.favoritesButton.checkbox.isHighlighted = true
            }
        }
    }
}

extension FavoritesViewController: ScreenUpdaterProtocol {
    
    func updateScreen() {
        if needUpdateSnapshot {
            needUpdateSnapshot = false
            
            if !textFilter.isEmpty {
                performQuery(with: textFilter)
            } else {
                updateSnapshot()
            }
            
            collectionView.indexPathsForVisibleItems.forEach { indexPath in
                guard let cell = collectionView.cellForItem(at: indexPath) as? FavoritesPlainCollectionViewCell else {
                    return
                }
                cell.favoritesButton.checkbox.isHighlighted = true
            }
        }
    }
}
