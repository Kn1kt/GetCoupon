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
    
    let segmentedCell: CellData = CellData(title: "", subtitle: "")
    let segmentedSection: SectionData = SectionData(sectionTitle: "")
    
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource
        <SectionData, CellData>! = nil
    
    var currentSnapshot: NSDiffableDataSourceSnapshot
        <SectionData, CellData>! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        segmentedSection.cells.append(segmentedCell)
        
        favoritesDataController.snapshotUpdater = self
        configureCollectionView()
        configureDataSource()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if needUpdateSnapshot {
            needUpdateSnapshot = false
            updateSnapshot()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if needUpdateDataSource {
            needUpdateDataSource = false
            favoritesDataController.checkCollection()
        }
        
    }
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
                return self.createSegmentedControlSection(layoutEnvironment)
            default:
                return self.createPlainSection(layoutEnvironment)
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider,
                                                         configuration: config)
        
        return layout
    }
    
    func createSegmentedControlSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 10)
        
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
            groupFractionHeigh = CGFloat(0.45)
            
        case (.regular, .compact):
            groupFractionHeigh = CGFloat(0.35)
            
        case (.regular, .regular):
            groupFractionHeigh = CGFloat(0.2)
            
        default:
            groupFractionHeigh = CGFloat(0.2)
        }
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(groupFractionHeigh))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
        
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
        view.addSubview(collectionView)
        
        // No need delegete for this step
        //collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
        
        collectionView.register(SegmentedControlCollectionViewCell.self,
                                forCellWithReuseIdentifier: SegmentedControlCollectionViewCell.reuseIdentifier)
        
        collectionView.register(FavoritesPlainCollectionViewCell.self,
                                forCellWithReuseIdentifier: FavoritesPlainCollectionViewCell.reuseIdentifier)
        
        collectionView.register(TitleSupplementaryView.self,
                                forSupplementaryViewOfKind: FavoritesViewController.titleElementKind,
                                withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
            <SectionData, CellData> (collectionView: collectionView) { [weak self] (collectionView: UICollectionView,
                                                                                indexPath: IndexPath,
                                                                                cellData: CellData) -> UICollectionViewCell? in
                
                guard let self = self else { return nil }
                
                switch indexPath.section {
                case 0:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SegmentedControlCollectionViewCell.reuseIdentifier,
                                                                        for: indexPath) as? SegmentedControlCollectionViewCell else {
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
                    
                    cell.titleLabel.text = cellData.title
                    cell.subtitleLabel.text = cellData.subtitle
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
                titleSupplementary.label.text = section.sectionTitle
                
                return titleSupplementary
            } else {
                fatalError("Can't create new supplementary")
            }
            
        }
        
        currentSnapshot = NSDiffableDataSourceSnapshot
            <SectionData, CellData>()
        
        currentSnapshot.appendSections([segmentedSection])
        currentSnapshot.appendItems(segmentedSection.cells)
        
        favoritesDataController.collectionsBySections.forEach { collection in
            currentSnapshot.appendSections([collection])
            currentSnapshot.appendItems(collection.cells)
        }
        
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}

    // MARK: - Updating snapshot
extension FavoritesViewController: SnapshotUpdaterProtocol {
    
    func updateSnapshot() {
        currentSnapshot = NSDiffableDataSourceSnapshot
        <SectionData, CellData>()

        currentSnapshot.appendSections([segmentedSection])
        currentSnapshot.appendItems(segmentedSection.cells)

        switch sortType {
        case 0:
            favoritesDataController.collectionsBySections.forEach { collection in
                currentSnapshot.appendSections([collection])
                currentSnapshot.appendItems(collection.cells)
            }
        default:
            let section = SectionData(sectionTitle: "", cells: favoritesDataController.collectionsByDates)
            currentSnapshot.appendSections([section])
            currentSnapshot.appendItems(section.cells)
        }
        
        dataSource.apply(currentSnapshot, animatingDifferences: true)
        
    }
}

    // MARK: - Actions
extension FavoritesViewController {
    
    @objc func selectedSegmentDidChange(_ segmentedControl: UISegmentedControl) {
        sortType = segmentedControl.selectedSegmentIndex
        
        if needUpdateDataSource {
            needUpdateDataSource = false
            favoritesDataController.checkCollection()
        }
        
        updateSnapshot()
    }
}

extension FavoritesViewController {
    
    // Add to Favorites
    @objc func addToFavorites(_ sender: AddToFavoritesButton) {
        
        //guard let cellIndex = sender.cellIndex else { return }
        guard let cell = sender.cell else { return }
        
        cell.isFavorite = !cell.isFavorite
        sender.checkbox.isHighlighted = cell.isFavorite
        
        if !cell.isFavorite {
            needUpdateDataSource = true
        }
    }
}
