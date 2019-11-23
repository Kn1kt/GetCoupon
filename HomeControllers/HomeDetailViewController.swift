//
//  HomeDetailViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 22.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class HomeDetailViewController: UIViewController {
    
    let section: HomeSectionData
    
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource
        <HomeSectionData, HomeCellData>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot
        <HomeSectionData, HomeCellData>! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = section.sectionTitle
        configureCollectionView()
        configureDataSource()
    }
    
    init(section: HomeSectionData) {
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
            groupFractionHeigh = CGFloat(0.35)
            
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
        
        return section
    }
}

// MARK: - Setup Table View

extension HomeDetailViewController {
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGroupedBackground
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
            <HomeSectionData, HomeCellData> (collectionView: collectionView) { (collectionView: UICollectionView,
                                                                                indexPath: IndexPath,
                                                                                cellData: HomeCellData) -> UICollectionViewCell? in
                
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
                    
                    return cell
                    
                default:
                    return nil
                }
                
        }
        
        currentSnapshot = NSDiffableDataSourceSnapshot
            <HomeSectionData, HomeCellData>()
        currentSnapshot.appendSections([section])
        currentSnapshot.appendItems(section.cells)
        
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}
