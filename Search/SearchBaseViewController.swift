//
//  SearchViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 04.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class SearchBaseViewController: UIViewController {

    var section: SectionData! = SectionData(sectionTitle: "Empty")
    
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource
        <SectionData, CellData>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot
        <SectionData, CellData>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor(named: "BlueTintColor")
        
        configureCollectionView()
        configureDataSource()
    }
}

    // MARK: - Layouts

extension SearchBaseViewController {
    
    func createLayout() -> UICollectionViewLayout {
        
        let sectionProvider = { [weak self] (sectionIndex: Int,
                                             layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            return self.createPlainSection(layoutEnvironment: layoutEnvironment)
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        //config.interSectionSpacing = 20
        
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
            groupFractionHeigh = CGFloat(0.1)
            
        case (.compact, .compact):
            groupFractionHeigh = CGFloat(0.2)
            
        case (.regular, .compact):
            groupFractionHeigh = CGFloat(0.35)
            
        case (.regular, .regular):
            groupFractionHeigh = CGFloat(0.25)
            
        default:
            groupFractionHeigh = CGFloat(0.1)
        }

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(groupFractionHeigh))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
        
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        
        return section
    }
}

    // MARK: - Setup Collection View

extension SearchBaseViewController {
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        view.addSubview(collectionView)
        
        // No need delegete for this step
        //collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
        
        
        collectionView.register(SearchPlainCollectionViewCell.self,
                                forCellWithReuseIdentifier: SearchPlainCollectionViewCell.reuseIdentifier)
        
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
            <SectionData, CellData> (collectionView: collectionView) { [weak self] (collectionView: UICollectionView,
                                                                                indexPath: IndexPath,
                                                                                cellData: CellData) -> UICollectionViewCell? in
                
                guard let self = self else {
                    return nil
                }
                
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchPlainCollectionViewCell.reuseIdentifier,
                                                                    for: indexPath) as? SearchPlainCollectionViewCell else {
                    fatalError("Can't create new cell")
                }
                
                if let image = cellData.image {
                    cell.imageView.image = image
                }
                
                cell.titleLabel.text = cellData.title
                cell.subtitleLabel.text = cellData.subtitle
                
                if indexPath.row == self.currentSnapshot.numberOfItems - 1 {
                    cell.separatorView.isHidden = true
                }
                
                return cell
                
        }
        
        currentSnapshot = NSDiffableDataSourceSnapshot
            <SectionData, CellData>()
        
        currentSnapshot.appendSections([section])
        currentSnapshot.appendItems(section.cells)
        
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}

    // MARK: - Update Snapshot

extension SearchBaseViewController {
    
    func updateSnapshot() {
        
        if let cellData = currentSnapshot.itemIdentifiers.last,
            let indexPath = dataSource.indexPath(for: cellData),
            let cell = collectionView.cellForItem(at: indexPath) as? SearchPlainCollectionViewCell {
            cell.separatorView.isHidden = false
        }
        
        currentSnapshot = NSDiffableDataSourceSnapshot
            <SectionData, CellData>()
        
        currentSnapshot.appendSections([section])
        currentSnapshot.appendItems(section.cells)
        
        dataSource.apply(currentSnapshot, animatingDifferences: true)
        
        if let cellData = currentSnapshot.itemIdentifiers.last,
            let indexPath = dataSource.indexPath(for: cellData),
            let cell = collectionView.cellForItem(at: indexPath) as? SearchPlainCollectionViewCell {
            cell.separatorView.isHidden = true
        }
    }
}
