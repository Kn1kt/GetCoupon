//
//  ShopViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 06.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ShopViewController: UIViewController {

    let shop: ShopData
    let dateFormatter = DateFormatter()
    
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource
        <ShopData, PromocodeData>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot
        <ShopData, PromocodeData>! = nil
    
    init(shop: ShopData) {
        self.shop = shop
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = shop.name
        navigationController?.navigationBar.prefersLargeTitles = true
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        configureCollectionView()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}

    // MARK: - Layouts

extension ShopViewController {
    
    func createLayout() -> UICollectionViewLayout {
        
        let sectionProvider = { [weak self] (sectionIndex: Int,
                                             layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
//            switch sectionIndex {
//            case 0:
//                return self.createSearchSection(layoutEnvironment)
//            case 1:
//                return self.createSegmentedControlSection(layoutEnvironment)
//            default:
                return self.createPlainSection(layoutEnvironment)
//            }
            
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        //config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider,
                                                        configuration: config)
        
        return layout
    }
    
    func createPlainSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
        
        var groupFractionHeigh: CGFloat! = nil
        
        switch (layoutEnvironment.traitCollection.horizontalSizeClass, layoutEnvironment.traitCollection.verticalSizeClass) {
        case (.compact, .regular):
            groupFractionHeigh = CGFloat(0.2)
            
        case (.compact, .compact):
            groupFractionHeigh = CGFloat(0.4)
            
        case (.regular, .compact):
            groupFractionHeigh = CGFloat(0.35)
            
        case (.regular, .regular):
            groupFractionHeigh = CGFloat(0.25)
            
        default:
            groupFractionHeigh = CGFloat(0.2)
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

extension ShopViewController {
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
        
        // No need delegete for this step
        //collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
        
        
        collectionView.register(ShopPlainCollectionViewCell.self,
                                forCellWithReuseIdentifier: ShopPlainCollectionViewCell.reuseIdentifier)
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
            <ShopData, PromocodeData> (collectionView: collectionView) { [weak self] (collectionView: UICollectionView,
                                                                                indexPath: IndexPath,
                                                                                cellData: PromocodeData) -> UICollectionViewCell? in
                
                guard let self = self else {
                    return nil
                }
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopPlainCollectionViewCell.reuseIdentifier,
                                                                    for: indexPath) as? ShopPlainCollectionViewCell else {
                    fatalError("Can't create new cell")
                }
                
                cell.imageView.setNeedsLayout()
                cell.imageView.image = self.shop.previewImage
                cell.titleLabel.text = self.shop.name
                cell.subtitleLabel.text = cellData.description
                //cell.couponLabel.text = cellData.name
                cell.promocodeView.promocodeLabel.text = cellData.name
                
                if let addingDate = cellData.addingDate {
                    cell.addingDateLabel.text = "Posted: " + self.dateFormatter.string(from: addingDate)
                }
                if let estimatedDate = cellData.estimatedDate {
                    cell.estimatedDateLabel.text = "Expiration date: " + self.dateFormatter.string(from: estimatedDate)
                }
                
                return cell
                
        }
        
        currentSnapshot = NSDiffableDataSourceSnapshot
            <ShopData, PromocodeData>()
        
        currentSnapshot.appendSections([shop])
        currentSnapshot.appendItems(shop.promocodes)
        
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}
