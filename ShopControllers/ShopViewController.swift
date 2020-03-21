//
//  ShopViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 06.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ShopViewController: UIViewController {
  
  //    var previousViewUpdater: ScreenUpdaterProtocol?
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)

  private var viewModel: ShopViewModel!
  
//  let shop: ShopData
//  let favoriteStatus: Bool
  private let dateFormatter = DateFormatter()
  private let headerImageView = UIImageView()
  private let logoView = LogoWithFavoritesButton()
  
  private let titleCell: PromoCodeData = PromoCodeData(coupon: "title")
  private let titleSection: ShopData
  
  private let detailTitleCell: PromoCodeData = PromoCodeData(coupon: "detailTitle")
  private let detailTitleSection: ShopData
  
  var collectionView: UICollectionView! = nil
  var dataSource: UICollectionViewDiffableDataSource
    <ShopData, PromoCodeData>! = nil
  var currentSnapshot: NSDiffableDataSourceSnapshot
    <ShopData, PromoCodeData>! = nil
  
  init() {
//    self.shop = shop
//    favoriteStatus = shop.isFavorite
    titleSection = ShopData(name: "title", shortDescription: "title", websiteLink: "", promoCodes: [titleCell])
    detailTitleSection = ShopData(name: "detail", shortDescription: "detail", websiteLink: "", promoCodes: [detailTitleCell])
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func createWith(viewModel: ShopViewModel) -> ShopViewController {
    let vc = ShopViewController()
    vc.viewModel = viewModel
    
    return vc
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    
    configureNavigationController(self.navigationController)
//    navigationController?.navigationBar.prefersLargeTitles = false
//    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//    navigationController?.navigationBar.shadowImage = UIImage()
//    navigationController?.navigationBar.isTranslucent = true
//    navigationController?.navigationBar.alpha = 0.1
    
//    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(ShopViewController.backButtonTapped(_:)))
//    logoView.favoritesButton.addTarget(self, action: #selector(ShopViewController.addToFavorites(_:)), for: .touchUpInside)
//    logoView.favoritesButton.checkbox.isHighlighted = shop.isFavorite
    
//    updateImages()
    
    configureCollectionView()
    configureDataSource()
    
    bindViewModel()
    bindUI()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    viewModel.controllerWillDisappear.accept(())
    
//    if favoriteStatus != shop.isFavorite {
//      let cache = CacheController()
//      cache.shop(with: shop.name, isFavorite: shop.isFavorite, date: shop.favoriteAddingDate)
//
//      if shop.isFavorite {
//        ModelController.insertInFavorites(shop: shop)
//      } else {
//        ModelController.deleteFromFavorites(shop: shop)
//      }
//      previousViewUpdater?.updateScreen()
//    }
  }
  
  private func bindUI() {
    viewModel.favoriteButtonEnabled
      .drive(logoView.favoritesButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    viewModel.favoriteButtonEnabled
      .filter { !$0 }
      .map { _ in CGFloat(0.5) }
      .drive(logoView.favoritesButton.checkbox.rx.alpha)
      .disposed(by: disposeBag)
    
    viewModel.favoriteButtonEnabled
      .drive(onNext: { b in
        print("isEnabled \(b)")
      })
      .disposed(by: disposeBag)
    
    viewModel.shop
      .drive(onNext: { [weak self] shop in
        self?.configureLogoView(shop: shop)
      })
      .disposed(by: disposeBag)
    
    viewModel.shop
      .drive(onNext: { [weak self] shop in
        self?.updateSnapshot(shop)
      })
      .disposed(by: disposeBag)
    
    viewModel.shop
      .drive(onNext: { [weak self] shop in
        self?.updateImages(shop: shop)
      })
      .disposed(by: disposeBag)
  }
  
  private func bindViewModel() {
    logoView.favoritesButton.rx.tap
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] in
        self.viewModel.updateFavoritesStatus()
        UIView.animate(withDuration: 0.15) {
          self.logoView.favoritesButton.checkbox.isHighlighted = self.viewModel.currentShop.isFavorite
        }
      })
      .disposed(by: disposeBag)
    
    logoView.favoritesButton.rx.tap
      .observeOn(self.eventScheduler)
      .bind(to: self.viewModel.shopIsFavoriteChanged)
      .disposed(by: disposeBag)
  }
  
  private func configureLogoView(shop: ShopData) {
//    logoView.favoritesButton.addTarget(self, action: #selector(ShopViewController.addToFavorites(_:)), for: .touchUpInside)
    logoView.favoritesButton.checkbox.isHighlighted = shop.isFavorite
  }
  
  private func configureNavigationController(_ nc: UINavigationController?) {
    nc?.navigationBar.prefersLargeTitles = false
    nc?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    nc?.navigationBar.shadowImage = UIImage()
    nc?.navigationBar.isTranslucent = true
    nc?.navigationBar.alpha = 0.1
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
    navigationItem.rightBarButtonItem?.rx.tap
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: { debugPrint("Shop did dismiss") })
      })
      .disposed(by: disposeBag)
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
    headerImageView.backgroundColor = viewModel.currentShop.placeholderColor
    view.addSubview(headerImageView)
    
    logoView.frame = CGRect(x: view.center.x - 70,
                            y: 110,
                            width: 140,
                            height: 140)
    
    logoView.imageView.backgroundColor = viewModel.currentShop.placeholderColor
    view.addSubview(logoView)
    
    // Setup delegate
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
          cell.titleLabel.text = self.viewModel.currentShop.name
          cell.subtitleLabel.text = self.viewModel.currentShop.description
          
          return cell
          
        case 1:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopDetailTitleCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as? ShopDetailTitleCollectionViewCell else {
                                                                fatalError("Can't create new cell")
          }
          
          cell.couponsCount.imageDescription.text = "\(self.viewModel.currentShop.promoCodes.count) Coupons"
          cell.couponsCount.imageView.tintColor = UIColor(named: "BlueTintColor")
          cell.couponsCount.imageDescription.textColor = UIColor(named: "BlueTintColor")
          
//          cell.website.button.addTarget(self, action: #selector(ShopViewController.openWebsite(_:)), for: .touchUpInside)
          cell.website.button.rx.tap
            .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribeOn(self.eventScheduler)
            .observeOn(self.eventScheduler)
            .bind(to: self.viewModel.websiteButton)
            .disposed(by: cell.disposeBag)
          
          return cell
          
        default:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopPlainCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as? ShopPlainCollectionViewCell else {
                                                                fatalError("Can't create new cell")
          }
          
          cell.imageView.backgroundColor = self.viewModel.currentShop.placeholderColor
          cell.imageView.image = self.viewModel.currentShop.previewImage
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
    
//    currentSnapshot.appendSections([shop])
//    currentSnapshot.appendItems(shop.promoCodes)
    
    dataSource.apply(currentSnapshot, animatingDifferences: false)
  }
  
  
}

  // MARK: - Interaction
extension ShopViewController {
  
  func updateSnapshot(_ shop: ShopData) {
    
    currentSnapshot = NSDiffableDataSourceSnapshot
      <ShopData, PromoCodeData>()
    
    currentSnapshot.appendSections([titleSection])
    currentSnapshot.appendItems(titleSection.promoCodes)
    
    currentSnapshot.appendSections([detailTitleSection])
    currentSnapshot.appendItems(detailTitleSection.promoCodes)
    
    currentSnapshot.appendSections([shop])
    currentSnapshot.appendItems(shop.promoCodes)

    dataSource.apply(currentSnapshot, animatingDifferences: true)
    
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
        self.navigationItem.title = self.viewModel.currentShop.name
        
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
  
//  @objc func backButtonTapped(_ sender: UIBarButtonItem) {
//    dismiss(animated: true, completion: { debugPrint("Shop did dismiss") })
//  }
  
//  @objc func addToFavorites(_ sender: AddToFavoritesButton) {
//    shop.isFavorite = !shop.isFavorite
//
//    UIView.animate(withDuration: 0.15) { [weak self] in
//      guard let self = self else { return }
//      sender.checkbox.isHighlighted = self.shop.isFavorite
//    }
//
//    if shop.isFavorite {
//      shop.favoriteAddingDate = Date(timeIntervalSinceNow: 0)
//    } else {
//      shop.favoriteAddingDate = nil
//    }
//  }
  
  func updateVisibleItems(shop: ShopData) {
    let indexPaths = collectionView.indexPathsForVisibleItems
    
    indexPaths.forEach { indexPath in
      guard let cell = collectionView.cellForItem(at: indexPath) as? ShopPlainCollectionViewCell else {
        return
      }
      
      cell.imageView.image = shop.previewImage
    }
  }
}

  //MARK: - Setup Images
extension ShopViewController {
  
  private func updateImages(shop: ShopData) {
    if let headerImage = shop.image {
      headerImageView.image = headerImage
    } else {
      headerImageView.image = shop.previewImage
      headerImageView.alpha = 0.3
//      setupHeaderImage()
      viewModel.setupImage(for: shop)
        .observeOn(MainScheduler.instance)
        .subscribe(onCompleted: {
          UIView.animate(withDuration: 1) {
            if let image = shop.image {
              self.headerImageView.alpha = 0.1
              self.headerImageView.image = image
              self.headerImageView.alpha = 1
            }
          }
        })
        .disposed(by: disposeBag)
    }
    
    if let logoImage = shop.previewImage {
      logoView.imageView.image = logoImage
    } else {
//      setupPreviewImage()
      viewModel.setupPreviewImage(for: shop)
        .observeOn(MainScheduler.instance)
        .subscribe(onCompleted: {
          self.logoView.imageView.image = shop.previewImage
          self.updateVisibleItems(shop: shop)
        })
        .disposed(by: disposeBag)
    }
  }
  
//  private func setupPreviewImage() {
//    NetworkController.setupPreviewImage(in: shop) {
//      DispatchQueue.main.async { [weak self] in
//        self?.logoView.imageView.image = self?.shop.previewImage
//        self?.updateVisibleItems()
//      }
//    }
//  }
//
//  private func setupHeaderImage() {
//    NetworkController.setupImage(in: shop) {
//      DispatchQueue.main.async { [weak self] in
//        UIView.animate(withDuration: 1) {
//          if let image = self?.shop.image {
//            self?.headerImageView.alpha = 0.1
//            self?.headerImageView.image = image
//            self?.headerImageView.alpha = 1
//          }
//        }
//      }
//    }
//  }
}

//  //MARK: - openURL
//extension ShopViewController {
//  
//  func openWebsite(_ button: UIButton) {
//    button.rx.tap
//      .observeOn(MainScheduler.instance)
//      .bind(to: viewModel.websiteButton)
//      .disposed(by: disposeBag)
////    guard let url = URL(string: shop.websiteLink) else {
////      return
////    }
////    UIApplication.shared.open(url)
//  }
//}
