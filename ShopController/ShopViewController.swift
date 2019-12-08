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
    let favoriteStatus: Bool
    let dateFormatter = DateFormatter()
    let headerImageView = UIImageView()
    let logoView = LogoWithFavoritesButton()
    
    let titleCell: PromocodeData = PromocodeData(name: "title")
    let titleSection: ShopData
    
    let detailTitleCell: PromocodeData = PromocodeData(name: "detailTitle")
    let detailTitleSection: ShopData
    
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource
        <ShopData, PromocodeData>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot
        <ShopData, PromocodeData>! = nil
    
    init(shop: ShopData) {
        self.shop = shop
        favoriteStatus = shop.isFavorite
        titleSection = ShopData(name: "title", shortDescription: "title", websiteLink: "", promocodes: [titleCell])
        detailTitleSection = ShopData(name: "detail", shortDescription: "detail", websiteLink: "", promocodes: [detailTitleCell])
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        navigationController?.navigationBar.tintColor = UIColor(named: "BlueTintColor")
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.alpha = 0.1
        
        //navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(ShopViewController.backButtonTapped(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left.circle.fill"), style: .plain, target: self, action: #selector(ShopViewController.backButtonTapped(_:)))
        logoView.favoritesButton.addTarget(self, action: #selector(ShopViewController.addToFavorites(_:)), for: .touchUpInside)
        logoView.favoritesButton.checkbox.isHighlighted = shop.isFavorite
        
        configureCollectionView()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if favoriteStatus != shop.isFavorite {
            switch shop.isFavorite {
            case true:
                ModelController.insertInFavorites(shop: shop)
            case false:
                ModelController.deleteFromFavorites(shop: shop)
            }
        }
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//
//        logoView.layer.cornerRadius = logoView.bounds.size.height * 0.5
//        logoView.imageView.layer.cornerRadius = logoView.imageView.bounds.size.height * 0.5
//        logoView.favoritesButton.layer.cornerRadius = logoView.favoritesButton.bounds.height * 0.5
//    }
}

    // MARK: - Layouts

extension ShopViewController {
    
    func createLayout() -> UICollectionViewLayout {
        
        let sectionProvider = { [weak self] (sectionIndex: Int,
                                             layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            switch sectionIndex {
            case 0:
                return self.createTitleSection(layoutEnvironment)
            case 1:
                return self.createDetailTitleSection(layoutEnvironment)
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
    
    func createTitleSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        var groupFractionHeigh: CGFloat! = nil
        
        switch (layoutEnvironment.traitCollection.horizontalSizeClass, layoutEnvironment.traitCollection.verticalSizeClass) {
        case (.compact, .regular):
            groupFractionHeigh = CGFloat(0.12)
            
        case (.compact, .compact):
            groupFractionHeigh = CGFloat(0.25)
            
        case (.regular, .compact):
            groupFractionHeigh = CGFloat(0.35)
            
        case (.regular, .regular):
            groupFractionHeigh = CGFloat(0.25)
            
        default:
            groupFractionHeigh = CGFloat(0.12)
        }
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(groupFractionHeigh))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
        
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 55, leading: 10, bottom: 0, trailing: 10)
        
        return section
    }
    
    func createDetailTitleSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        var groupFractionHeigh: CGFloat! = nil
        
        switch (layoutEnvironment.traitCollection.horizontalSizeClass, layoutEnvironment.traitCollection.verticalSizeClass) {
        case (.compact, .regular):
            groupFractionHeigh = CGFloat(0.08)
            
        case (.compact, .compact):
            groupFractionHeigh = CGFloat(0.15)
            
        case (.regular, .compact):
            groupFractionHeigh = CGFloat(0.35)
            
        case (.regular, .regular):
            groupFractionHeigh = CGFloat(0.25)
            
        default:
            groupFractionHeigh = CGFloat(0.08)
        }
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(groupFractionHeigh))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
        
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
        
        return section
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
        //logoView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        view.addSubview(collectionView)
        
        //  Setup header image
        collectionView.contentInset = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)
        headerImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200)
        headerImageView.backgroundColor = .systemGray3
        
        headerImageView.image = shop.image
        
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        
        view.addSubview(headerImageView)
        
        logoView.frame = CGRect(x: view.center.x - 70,
                                y: 110,
                                width: 140,
                                height: 140)
        
        logoView.imageView.image = shop.previewImage
        
        view.addSubview(logoView)
        
        /// Setup delegate
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            //logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //logoView.centerYAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: -20),
            
            //logoView.heightAnchor.constraint(equalToConstant: 140),
            //logoView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.37),
            
            //logoView.widthAnchor.constraint(equalTo: logoView.heightAnchor)
        ])
        
        
        collectionView.register(ShopPlainCollectionViewCell.self,
                                forCellWithReuseIdentifier: ShopPlainCollectionViewCell.reuseIdentifier)
        
        collectionView.register(ShopTitleCollectionViewCell.self,
                                forCellWithReuseIdentifier: ShopTitleCollectionViewCell.reuseIdentifier)
        
        collectionView.register(ShopDetailTitleCollectionViewCell.self,
                                forCellWithReuseIdentifier: ShopDetailTitleCollectionViewCell.reuseIdentifier)
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
            <ShopData, PromocodeData> (collectionView: collectionView) { [weak self] (collectionView: UICollectionView,
                                                                                indexPath: IndexPath,
                                                                                cellData: PromocodeData) -> UICollectionViewCell? in
                
                guard let self = self else {
                    return nil
                }
                
                switch indexPath.section {
                case 0:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopTitleCollectionViewCell.reuseIdentifier,
                                                                        for: indexPath) as? ShopTitleCollectionViewCell else {
                        fatalError("Can't create new cell")
                    }
                    cell.titleLabel.text = self.shop.name
                    cell.subtitleLabel.text = self.shop.description
                    
                    return cell
                    
                case 1:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopDetailTitleCollectionViewCell.reuseIdentifier,
                                                                        for: indexPath) as? ShopDetailTitleCollectionViewCell else {
                        fatalError("Can't create new cell")
                    }
                    
                    cell.couponsCount.imageDescription.text = "\(self.shop.promocodes.count) Coupons"
                    cell.couponsCount.imageView.tintColor = UIColor(named: "BlueTintColor")
                    cell.couponsCount.imageDescription.textColor = UIColor(named: "BlueTintColor")
                    return cell
                    
                default:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopPlainCollectionViewCell.reuseIdentifier,
                                                                        for: indexPath) as? ShopPlainCollectionViewCell else {
                        fatalError("Can't create new cell")
                    }
                    
                    cell.imageView.setNeedsLayout()
                    cell.imageView.image = self.shop.previewImage
                    //cell.titleLabel.text = self.shop.name
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
        }
        
        currentSnapshot = NSDiffableDataSourceSnapshot
            <ShopData, PromocodeData>()
        
        currentSnapshot.appendSections([titleSection])
        currentSnapshot.appendItems(titleSection.promocodes)
        
        currentSnapshot.appendSections([detailTitleSection])
        currentSnapshot.appendItems(detailTitleSection.promocodes)
        
        currentSnapshot.appendSections([shop])
        currentSnapshot.appendItems(shop.promocodes)
        
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}

    //MARK: - Custom Header
extension ShopViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 200 - (scrollView.contentOffset.y + 200)
        
        let height = min(max(y, 0), UIScreen.main.bounds.size.height)
        let offset: CGFloat
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.compact, .regular):
            offset = CGFloat(-35)
            
        case (.compact, .compact):
            offset = CGFloat(-55)
            
        default:
            offset = CGFloat(-35)
        }
        
        if let navBar = navigationController?.navigationBar {
            if navBar.backgroundImage(for: .default) != nil
                && y < offset {
                //UIView.animate(withDuration: 2) {
                    navBar.setBackgroundImage(nil, for: .default)
                    navBar.shadowImage = nil
                    self.navigationItem.title = self.shop.name
                //}

            } else if navBar.backgroundImage(for: .default) == nil
                && y > offset {
                //UIView.animate(withDuration: 2) {
                    navBar.setBackgroundImage(UIImage(), for: .default)
                    navBar.shadowImage = UIImage()
                    self.navigationItem.title = nil
                //}
            }
        }
        
        logoView.frame = CGRect(x: view.center.x - 70, y: y - 90, width: 140, height: 140)
        headerImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
    }
}


extension ShopViewController {
    
    @objc func backButtonTapped(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: {debugPrint("Shop did dismiss")})
    }
    
    @objc func addToFavorites(_ sender: AddToFavoritesButton) {
        
        shop.isFavorite = !shop.isFavorite
        
        UIView.animate(withDuration: 0.15) { [weak self] in
            guard let self = self else { return }
            sender.checkbox.isHighlighted = self.shop.isFavorite
        }
        
        if shop.isFavorite {
            shop.favoriteAddingDate = Date(timeIntervalSinceNow: 0)
        } else {
            shop.favoriteAddingDate = nil
        }
    }
}
