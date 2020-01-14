//
//  ShopViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 06.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

protocol ScreenUpdaterProtocol {
    func updateScreen()
}

class ShopViewController: UIViewController {

    var previousViewUpdater: ScreenUpdaterProtocol?
    
    let queue = OperationQueue()
    
    let shop: ShopData
    let favoriteStatus: Bool
    let dateFormatter = DateFormatter()
    let headerImageView = UIImageView()
    let logoView = LogoWithFavoritesButton()
    
    let titleCell: PromoCodeData = PromoCodeData(coupon: "title")
    let titleSection: ShopData
    
    let detailTitleCell: PromoCodeData = PromoCodeData(coupon: "detailTitle")
    let detailTitleSection: ShopData
    
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource
        <ShopData, PromoCodeData>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot
        <ShopData, PromoCodeData>! = nil
    
    init(shop: ShopData) {
        self.shop = shop
        favoriteStatus = shop.isFavorite
        titleSection = ShopData(name: "title", shortDescription: "title", websiteLink: "", promoCodes: [titleCell])
        detailTitleSection = ShopData(name: "detail", shortDescription: "detail", websiteLink: "", promoCodes: [detailTitleCell])
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.alpha = 0.1
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(ShopViewController.backButtonTapped(_:)))
        logoView.favoritesButton.addTarget(self, action: #selector(ShopViewController.addToFavorites(_:)), for: .touchUpInside)
        logoView.favoritesButton.checkbox.isHighlighted = shop.isFavorite
        
        updateImages()
        
        configureCollectionView()
        configureDataSource()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if favoriteStatus != shop.isFavorite {
            let cache = CacheController()
            cache.shop(with: shop.name, isFavorite: shop.isFavorite, date: shop.favoriteAddingDate)
            switch shop.isFavorite {
            case true:
                ModelController.insertInFavorites(shop: shop)
            case false:
                ModelController.deleteFromFavorites(shop: shop)
            }
            previousViewUpdater?.updateScreen()
        }
    }
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
            groupFractionHeigh = CGFloat(0.10)
            
        case (.regular, .regular):
            groupFractionHeigh = CGFloat(0.10)
            
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
            groupFractionHeigh = CGFloat(0.10)
            
        case (.regular, .regular):
            groupFractionHeigh = CGFloat(0.10)
            
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
            groupFractionHeigh = CGFloat(0.20)
            
        case (.regular, .regular):
            groupFractionHeigh = CGFloat(0.20)
            
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
        collectionView.showsVerticalScrollIndicator = false
        view.addSubview(collectionView)
        
        //  Setup header image
        collectionView.contentInset = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)
        headerImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200)
        headerImageView.backgroundColor = .systemGray3
        
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        
        view.addSubview(headerImageView)
        
        logoView.frame = CGRect(x: view.center.x - 70,
                                y: 110,
                                width: 140,
                                height: 140)
        
        view.addSubview(logoView)
        
        /// Setup delegate
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
            <ShopData, PromoCodeData> (collectionView: collectionView) { [weak self] (collectionView: UICollectionView,
                                                                                indexPath: IndexPath,
                                                                                cellData: PromoCodeData) -> UICollectionViewCell? in
                
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
                    
                    cell.couponsCount.imageDescription.text = "\(self.shop.promoCodes.count) Coupons"
                    cell.couponsCount.imageView.tintColor = UIColor(named: "BlueTintColor")
                    cell.couponsCount.imageDescription.textColor = UIColor(named: "BlueTintColor")
                    
                    cell.website.button.addTarget(self, action: #selector(ShopViewController.openWebsite(_:)), for: .touchUpInside)
                    return cell
                    
                default:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopPlainCollectionViewCell.reuseIdentifier,
                                                                        for: indexPath) as? ShopPlainCollectionViewCell else {
                        fatalError("Can't create new cell")
                    }
                    
                    cell.imageView.image = self.shop.previewImage
                    cell.subtitleLabel.text = cellData.description
                    cell.promocodeView.promocodeLabel.text = cellData.coupon
                    
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
            <ShopData, PromoCodeData>()
        
        currentSnapshot.appendSections([titleSection])
        currentSnapshot.appendItems(titleSection.promoCodes)
        
        currentSnapshot.appendSections([detailTitleSection])
        currentSnapshot.appendItems(detailTitleSection.promoCodes)
        
        currentSnapshot.appendSections([shop])
        currentSnapshot.appendItems(shop.promoCodes)
        
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
                    navBar.setBackgroundImage(nil, for: .default)
                    navBar.shadowImage = nil
                    self.navigationItem.title = self.shop.name

            } else if navBar.backgroundImage(for: .default) == nil
                && y > offset {
                    navBar.setBackgroundImage(UIImage(), for: .default)
                    navBar.shadowImage = UIImage()
                    self.navigationItem.title = nil
            }
        }
        
        logoView.frame = CGRect(x: view.center.x - 70, y: y - 90, width: 140, height: 140)
        headerImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
    }
}

    // MARK: - Actions
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

    //MARK: - URLSessionDataTask
extension ShopViewController {
    
    private func updateImages() {
        if let headerImage = shop.image {
            headerImageView.image = headerImage
        } else {
            headerImageView.image = shop.previewImage
            headerImageView.alpha = 0.3
            setupHeaderImage()
        }
        if let logoImage = shop.previewImage {
            logoView.imageView.image = logoImage
        } else {
            setupPreviewImage()
        }
    }
    
    private func setupPreviewImage() {
        //DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            //guard let self = self else { return }
               
            //let cache = CacheController()
            //cache.setPreviewImage(for: cellData)
            let op = SetupPreviewImageOperation(shop: shop)
            op.completionBlock = {
                DispatchQueue.main.async { [weak self] in
                    self?.logoView.imageView.image = self?.shop.previewImage
                }
            }
            self.queue.addOperation(op)
        //}
    }
    
    private func setupHeaderImage() {
        let op = SetupImageOperation(shop: shop)
        op.completionBlock = {
            DispatchQueue.main.async { [weak self] in
                UIView.animate(withDuration: 1) {
                    self?.headerImageView.alpha = 0.1
                    self?.headerImageView.image = self?.shop.image
                    self?.headerImageView.alpha = 1
                }
            }
        }
        self.queue.addOperation(op)
    }
}

    //MARK: - openURL
extension ShopViewController {
    
    @objc func openWebsite(_ sender: UIButton) {
        guard let url = URL(string: shop.websiteLink) else {
            return
        }
        UIApplication.shared.open(url)
    }
}
