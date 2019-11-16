//
//  HomeViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    let homeDataController = HomeDataController()
    static let titleElementKind = "title-element-kind"
    
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource
        <HomeSectionData, HomeCellData>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot
        <HomeSectionData, HomeCellData>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Home"
        configureCollectionView()
        configureDataSource()
        
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

extension HomeViewController {
    
    func createLayout() -> UICollectionViewLayout {
        
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(0.5))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension:
                                                                                                    .fractionalWidth(1.0),
                                                                                                    heightDimension:                            .fractionalHeight(1.0)),
                                                                 subitem: item,
                                                                 count: 2)
            
            //let groupFractionalWidth = CGFloat(layoutEnvironment.container.effectiveContentSize.width > 500 ? 0.425 : 0.85)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(170),
                                                   heightDimension: .absolute(320))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [verticalGroup])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            
            let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(44))
            let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize,
                                                                                elementKind: HomeViewController.titleElementKind,
                                                                                alignment: .top)
            section.boundarySupplementaryItems = [titleSupplementary]
            
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider,
                                                         configuration: config)
        
        return layout
    }
}

extension HomeViewController {
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGroupedBackground
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
        collectionView.register(HomeCollectionViewCell.self,
                                forCellWithReuseIdentifier: HomeCollectionViewCell.reuseIdentifier)
        collectionView.register(TitleSupplementaryView.self,
                                forSupplementaryViewOfKind: HomeViewController.titleElementKind, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
            <HomeSectionData, HomeCellData> (collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath,
                                                                                cellData: HomeCellData) -> UICollectionViewCell? in
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.reuseIdentifier,
                                                                    for: indexPath) as? HomeCollectionViewCell else {
                    fatalError("Can't create new cell")
                }
                cell.titleLabel.text = cellData.title
                cell.subtitleLabel.text = cellData.subtitle
                
                return cell
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
            <HomeSectionData, HomeCellData>()
        homeDataController.collections.forEach { collection in
            currentSnapshot.appendSections([collection])
            currentSnapshot.appendItems(collection.cells)
        }
        
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}
