//
//  HomeViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    let homeDataController = ModelController.homeDataController
    static let titleElementKind = "title-element-kind"
    static let showMoreElementKind = "show-more-element-kind"
    
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
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Home"
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

extension HomeViewController {
    
    func createLayout() -> UICollectionViewLayout {
        
        let sectionProvider = { [weak self] (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let self = self else { return nil }
            
            switch sectionIndex {
            case 0:
                return self.createCardSection(layoutEnvironment)
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
    
    func createCardSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
        
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension:
                                                                                                .fractionalWidth(1.0),
                                                                                                heightDimension:                            .fractionalHeight(1.0)),
                                                             subitem: item,
                                                             count: 2)
        
        var groupFractionalWidth: CGFloat! = nil
        var groupFractionHeigh: CGFloat! = nil
        
        switch (layoutEnvironment.traitCollection.horizontalSizeClass, layoutEnvironment.traitCollection.verticalSizeClass) {
        case (.compact, .regular):
            groupFractionalWidth = CGFloat(0.45)
            groupFractionHeigh = CGFloat(0.4)
            
        case (.compact, .compact):
            groupFractionalWidth = CGFloat(0.25)
            groupFractionHeigh = CGFloat(0.7)
            
        case (.regular, .compact):
            groupFractionalWidth = CGFloat(0.3)
            groupFractionHeigh = CGFloat(0.8)
            
        case (.regular, .regular):
            groupFractionalWidth = CGFloat(0.35)
            groupFractionHeigh = CGFloat(0.4)
            
        default:
            groupFractionalWidth = CGFloat(0.45)
            groupFractionHeigh = CGFloat(0.4)
        }
        
        //let groupFractionalWidth = CGFloat(layoutEnvironment.container.effectiveContentSize.width > 500 ? 0.3 : 0.45)
        //let groupFractionHeigh = CGFloat(layoutEnvironment.container.effectiveContentSize.height < 500 ? 0.8 : 0.5)
        
        //let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(170),
        //                                       heightDimension: .estimated(320))
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                               heightDimension: .fractionalHeight(groupFractionHeigh))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [verticalGroup])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(44))
        
        let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize,
                                                                            elementKind: HomeViewController.titleElementKind,
                                                                            alignment: .top)
        
        section.boundarySupplementaryItems = [titleSupplementary]
        
        return section
    }
    
    func createPlainSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
        
        var groupFractionalWidth: CGFloat! = nil
        var groupFractionHeigh: CGFloat! = nil
        
        switch (layoutEnvironment.traitCollection.horizontalSizeClass, layoutEnvironment.traitCollection.verticalSizeClass) {
        case (.compact, .regular):
            groupFractionalWidth = CGFloat(0.36)
            groupFractionHeigh = CGFloat(0.2)
            
        case (.compact, .compact):
            groupFractionalWidth = CGFloat(0.2)
            groupFractionHeigh = CGFloat(0.35)
            
        case (.regular, .compact):
            groupFractionalWidth = CGFloat(0.2)
            groupFractionHeigh = CGFloat(0.35)
            
        case (.regular, .regular):
            groupFractionalWidth = CGFloat(0.25)
            groupFractionHeigh = CGFloat(0.2)
            
        default:
            groupFractionalWidth = CGFloat(0.36)
            groupFractionHeigh = CGFloat(0.2)
        }
            
            
        //let groupFractionalWidth = CGFloat(layoutEnvironment.container.effectiveContentSize.width > 500 ? 0.2 : 0.36)
        //let groupFractionHeigh = CGFloat(layoutEnvironment.container.effectiveContentSize.height < 500 ? 0.4 : 0.25)
        
        //let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(135),
        //                                       heightDimension: .estimated(160))
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                               heightDimension: .fractionalHeight(groupFractionHeigh))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(44))
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(35))
        
        let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize,
                                                                             elementKind: HomeViewController.titleElementKind,
                                                                             alignment: .top)
        
        let footerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize,
                                                                              elementKind: HomeViewController.showMoreElementKind,
                                                                              alignment: .bottom)
        
        section.boundarySupplementaryItems = [titleSupplementary, footerSupplementary]
        
        return section
    }
}

// MARK: - Setup Collection View

extension HomeViewController {
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        view.addSubview(collectionView)
        // No need delegete for this step
        //collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
        collectionView.register(HomeCardCollectionViewCell.self,
                                forCellWithReuseIdentifier: HomeCardCollectionViewCell.reuseIdentifier)
        
        collectionView.register(HomeCaptionImageCollectionViewCell.self,
                                forCellWithReuseIdentifier: HomeCaptionImageCollectionViewCell.reuseIdentifier)
        
        collectionView.register(TitleSupplementaryView.self,
                                forSupplementaryViewOfKind: HomeViewController.titleElementKind,
                                withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
        
        collectionView.register(ShowMoreSupplementaryView.self,
                                forSupplementaryViewOfKind: HomeViewController.showMoreElementKind,
                                withReuseIdentifier: ShowMoreSupplementaryView.reuseIdentifier)
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
            <SectionData, CellData> (collectionView: collectionView) { (collectionView: UICollectionView,
                                                                                indexPath: IndexPath,
                                                                                cellData: CellData) -> UICollectionViewCell? in
                
                switch indexPath.section {
                case 0:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCardCollectionViewCell.reuseIdentifier,
                                                                        for: indexPath) as? HomeCardCollectionViewCell else {
                        fatalError("Can't create new cell")
                    }
                    
                    if let image = cellData.image {
                        cell.imageView.image = image
                    }
                    cell.titleLabel.text = cellData.title
                    cell.subtitleLabel.text = cellData.subtitle
                    
                    return cell
                    
                default:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCaptionImageCollectionViewCell.reuseIdentifier,
                                                                        for: indexPath) as? HomeCaptionImageCollectionViewCell else {
                        fatalError("Can't create new cell")
                    }
                    
                    if let image = cellData.image {
                        cell.imageView.image = image
                    }
                    cell.titleLabel.text = cellData.title
                    cell.subtitleLabel.text = cellData.subtitle
                    
                    return cell
                }
                
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            guard let self = self,
                let snapshot = self.currentSnapshot else {
                    return nil
            }
            
            switch kind {
            case HomeViewController.titleElementKind:
                if let titleSupplementary = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                            withReuseIdentifier: TitleSupplementaryView.reuseIdentifier,
                                                                                            for: indexPath) as? TitleSupplementaryView {
                    let section = snapshot.sectionIdentifiers[indexPath.section]
                    titleSupplementary.label.text = section.sectionTitle
                    
                    return titleSupplementary
                } else {
                    fatalError("Can't create new supplementary")
                }
            case HomeViewController.showMoreElementKind:
                if let footerSupplementary = collectionView.dequeueReusableSupplementaryView( ofKind: kind,
                                                                                             withReuseIdentifier: ShowMoreSupplementaryView.reuseIdentifier,
                                                                                             for: indexPath) as? ShowMoreSupplementaryView {
                    
                    footerSupplementary.showMoreButton.sectionIndex = indexPath.section
                    footerSupplementary.showMoreButton.addTarget(self, action: #selector(HomeViewController.showDetailList(_:)), for: .touchUpInside)
                    
                    return footerSupplementary
                } else {
                    fatalError("Can't create new supplementary")
                }
            default:
                fatalError("Can't find new supplementary")
            }
        }
        
        currentSnapshot = NSDiffableDataSourceSnapshot
            <SectionData, CellData>()
        homeDataController.collections.forEach { collection in
            currentSnapshot.appendSections([collection])
            currentSnapshot.appendItems(collection.cells)
        }
        
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}

// MARK: - Interaction

extension HomeViewController {
    
    // Show more button
    @objc func showDetailList(_ sender: ShowMoreUIButton) {
        guard let sectionIndex = sender.sectionIndex,
            let section = homeDataController.section(for: sectionIndex) else {
                return
        }
        
        let viewController = HomeDetailViewController(section: section)
        viewController.favoritesUpdater = homeDataController
        //print("tapped in \(section.sectionTitle)")
        
        show(viewController, sender: self)
    }
}
