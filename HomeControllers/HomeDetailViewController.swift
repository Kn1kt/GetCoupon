//
//  HomeDetailViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 22.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class HomeDetailViewController: UIViewController {
    
    let section: SectionData
    
    var editedCells: Set<CellData> = []
    
    var needUpdateFavorites: Bool = false
    
    var favoritesUpdater: FavoritesUpdaterProtocol?
    
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource
        <SectionData, CellData>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot
        <SectionData, CellData>! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = section.sectionTitle
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !editedCells.isEmpty || needUpdateFavorites {
            favoritesUpdater?.updateFavoritesCollections(in: section.sectionTitle, with: editedCells)
            //favoritesUpdater?.updateFavoritesCollections(in: section)
            editedCells.removeAll()
            needUpdateFavorites = false
        }
    }
    
    init(section: SectionData) {
        self.section = section
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                return self.createPlainSection(layoutEnvironment)
            default:
                return nil
            }
            
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider,
                                                        configuration: config)
        
        return layout
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

// MARK: - Setup Table View

extension HomeDetailViewController {
    
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
        
        
        collectionView.register(HomeDetailCollectionViewCell.self,
                                forCellWithReuseIdentifier: HomeDetailCollectionViewCell.reuseIdentifier)
        
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
            <SectionData, CellData> (collectionView: collectionView) { [weak self] (collectionView: UICollectionView,
                                                                                indexPath: IndexPath,
                                                                                cellData: CellData) -> UICollectionViewCell? in
                
                guard let self = self else {
                    return nil
                }
                
                switch indexPath.section {
                case 0:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeDetailCollectionViewCell.reuseIdentifier,
                                                                        for: indexPath) as? HomeDetailCollectionViewCell else {
                        fatalError("Can't create new cell")
                    }
                    
                    if let image = cellData.image {
                        cell.imageView.image = image
                    }
                    cell.titleLabel.text = cellData.title
                    cell.subtitleLabel.text = cellData.subtitle
                    cell.addToFavoritesButton.checkbox.isHighlighted = cellData.isFavorite
                    
                    cell.addToFavoritesButton.cellIndex = indexPath
                    cell.addToFavoritesButton.addTarget(self, action: #selector(HomeDetailViewController.addToFavorites(_:)), for: .touchUpInside)
                    
                    if indexPath.row == self.section.cells.count - 1 {
                        cell.separatorView.isHidden = true
                    }
                    
                    return cell
                    
                default:
                    return nil
                }
                
        }
        
        currentSnapshot = NSDiffableDataSourceSnapshot
            <SectionData, CellData>()
        currentSnapshot.appendSections([section])
        currentSnapshot.appendItems(section.cells)
        
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}

// MARK: - Interaction
extension HomeDetailViewController {
    
    // Add to Favorites
    @objc func addToFavorites(_ sender: AddToFavoritesButton) {
        
        guard let cellIndex = sender.cellIndex?.row else { return }
        let cell = section.cells[cellIndex]
        cell.isFavorite = !cell.isFavorite
        
        sender.checkbox.isHighlighted = cell.isFavorite
        
        if cell.isFavorite {
            cell.favoriteAddingDate = Date(timeIntervalSinceNow: 0)
        } else {
            cell.favoriteAddingDate = nil
        }
        
        if cell.isFavorite {
            editedCells.insert(cell)
        } else {
            if editedCells.remove(cell) == nil {
                needUpdateFavorites = true
            }
        }
    }
}
