//
//  HomeViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol CellWithImage {
  var imageView: UIImageView { get }
}

class HomeViewController: UIViewController {
  
  private let disposeBag = DisposeBag()
  private let defaultSheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private let viewModel: HomeViewModel = HomeViewModel()
  
  static let titleElementKind = "title-element-kind"
  static let showMoreElementKind = "show-more-element-kind"
  
  var collectionView: UICollectionView! = nil
  var dataSource: UICollectionViewDiffableDataSource
    <ShopCategoryData, ShopData>! = nil
  var currentSnapshot: NSDiffableDataSourceSnapshot
    <ShopCategoryData, ShopData>! = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.tintColor = UIColor(named: "BlueTintColor")
    
    configureCollectionView()
    configureDataSource()
    
    let refresh = UIRefreshControl()
    collectionView?.refreshControl = refresh
    
    bindViewModel()
    bindUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.prefersLargeTitles = false
    navigationItem.title = "Home"
  }
  
  private func bindViewModel() {
    if let refresh = collectionView.refreshControl {
      refresh.rx.controlEvent(.valueChanged)
        .map { _ in refresh.isRefreshing }
        .subscribeOn(eventScheduler)
        .observeOn(eventScheduler)
        .bind(to: viewModel.refresh)
        .disposed(by: disposeBag)
    }
    
    collectionView.rx.itemSelected
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] indexPath in
        self.collectionView.deselectItem(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .map { [unowned self] indexPath in
        let selectedShop = self.currentSnapshot.sectionIdentifiers[indexPath.section].shops[indexPath.row]
        return (self, selectedShop)
      }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: viewModel.showShopVC)
      .disposed(by: disposeBag)
  }
  
  private func bindUI() {
    if let refresh = collectionView.refreshControl {
      viewModel.endRefreshing
        .drive(refresh.rx.isRefreshing)
        .disposed(by: disposeBag)
    }
    
    viewModel.collections
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] collections in
        self?.updateSnapshot(collections)
      })
      .disposed(by: disposeBag)
  }
  
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
    config.interSectionSpacing = 10
    
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
      groupFractionalWidth = CGFloat(0.44)
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
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                           heightDimension: .fractionalHeight(groupFractionHeigh))
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [verticalGroup])
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
    section.interGroupSpacing = 10
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
    
    let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .estimated(53))
    
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
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                           heightDimension: .fractionalHeight(groupFractionHeigh))
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
    section.interGroupSpacing = 10
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
    
    let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .estimated(53))
//    let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                            heightDimension: .estimated(32))
    
    let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize,
                                                                         elementKind: HomeViewController.titleElementKind,
                                                                         alignment: .top)
    
//    let footerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize,
//                                                                          elementKind: HomeViewController.showMoreElementKind,
//                                                                          alignment: .bottom)
    
    section.boundarySupplementaryItems = [titleSupplementary]//, footerSupplementary]
    
    return section
  }
}

// MARK: - Setup Collection View
extension HomeViewController {
  
  func configureCollectionView() {
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .systemGroupedBackground
    collectionView.alwaysBounceVertical = true
    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    view.addSubview(collectionView)
    
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
    
//    collectionView.register(ShowMoreSupplementaryView.self,
//                            forSupplementaryViewOfKind: HomeViewController.showMoreElementKind,
//                            withReuseIdentifier: ShowMoreSupplementaryView.reuseIdentifier)
  }
  
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource
      <ShopCategoryData, ShopData> (collectionView: collectionView) { [unowned self] (collectionView: UICollectionView,
        indexPath: IndexPath,
        cellData: ShopData) -> UICollectionViewCell? in
        
        switch indexPath.section {
        case 0:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCardCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as? HomeCardCollectionViewCell else {
                                                                fatalError("Can't create new cell")
          }
          
          if let image = cellData.previewImage {
            cell.imageView.image = image
          } else {
            cell.imageView.backgroundColor = cellData.placeholderColor
            self.viewModel.setupImage(for: cellData)
              .observeOn(MainScheduler.instance)
              .subscribe(onCompleted: {
                cell.imageView.image = cellData.previewImage
              })
              .disposed(by: cell.disposeBag)
          }
          
          cell.titleLabel.text = cellData.name
          cell.subtitleLabel.text = cellData.shortDescription
          
          return cell
          
        default:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCaptionImageCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as? HomeCaptionImageCollectionViewCell else {
                                                                fatalError("Can't create new cell")
          }
          
          if let image = cellData.previewImage {
            cell.imageView.image = image
          } else {
            cell.imageView.backgroundColor = cellData.placeholderColor
            self.viewModel.setupImage(for: cellData)
              .observeOn(MainScheduler.instance)
              .subscribe(onCompleted: {
                cell.imageView.image = cellData.previewImage
              })
              .disposed(by: cell.disposeBag)
          }
          
          cell.titleLabel.text = cellData.name
          cell.subtitleLabel.text = cellData.shortDescription
          
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
          titleSupplementary.label.text = section.categoryName
          
          titleSupplementary.showMoreButton.sectionIndex = indexPath.section
          
          if indexPath.section != 0 {
            titleSupplementary.showMoreButton.isHidden = false
            titleSupplementary.showMoreButton.isEnabled = true
            
            titleSupplementary.showMoreButton.rx.tap
              .map { _ in (titleSupplementary.showMoreButton, self) }
              .subscribeOn(self.eventScheduler)
              .observeOn(self.eventScheduler)
              .bind(to: self.viewModel.showDetailVC)
              .disposed(by: titleSupplementary.disposeBag)
          }
          return titleSupplementary
        } else {
          fatalError("Can't create new supplementary")
        }
      case HomeViewController.showMoreElementKind:
        if let footerSupplementary = collectionView.dequeueReusableSupplementaryView( ofKind: kind,
                                                                                      withReuseIdentifier: ShowMoreSupplementaryView.reuseIdentifier,
                                                                                      for: indexPath) as? ShowMoreSupplementaryView {
          
          footerSupplementary.showMoreButton.sectionIndex = indexPath.section
          
          footerSupplementary.showMoreButton.rx.tap
            .map { _ in (footerSupplementary.showMoreButton, self) }
            .subscribeOn(self.eventScheduler)
            .observeOn(self.eventScheduler)
            .bind(to: self.viewModel.showDetailVC)
            .disposed(by: footerSupplementary.disposeBag)
          
          return footerSupplementary
        } else {
          fatalError("Can't create new supplementary")
        }
      default:
        fatalError("Can't find new supplementary")
      }
    }
    
    currentSnapshot = NSDiffableDataSourceSnapshot
      <ShopCategoryData, ShopData>()
    
    dataSource.apply(currentSnapshot, animatingDifferences: false)
  }
}

  // MARK: - Interaction
extension HomeViewController {
  
  private func updateSnapshot(_ collections: [ShopCategoryData]) {
    currentSnapshot = NSDiffableDataSourceSnapshot
      <ShopCategoryData, ShopData>()
    
    
    currentSnapshot = NSDiffableDataSourceSnapshot
      <ShopCategoryData, ShopData>()
    collections.forEach { collection in
      currentSnapshot.appendSections([collection])
      currentSnapshot.appendItems(collection.shops)
    }
      
    dataSource.apply(currentSnapshot, animatingDifferences: true)
  }
}
