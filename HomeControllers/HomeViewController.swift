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

class HomeViewController: UIViewController {
  
  static let titleElementKind = "title-element-kind"
  static let showMoreElementKind = "show-more-element-kind"
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private let viewModel = HomeViewModel()
  
  private let navBarTitleView = HomeAnimatingTitleView()
  private let navBarSubtitleView = HomeAnimatingSubtitleView()
  private var navBarSubtitleViewHeightConstraint: NSLayoutConstraint!
  
  var collectionView: UICollectionView! = nil
  var dataSource: UICollectionViewDiffableDataSource
    <ShopCategoryData, ShopData>! = nil
  var currentSnapshot: NSDiffableDataSourceSnapshot
    <ShopCategoryData, ShopData>! = nil
  
  let viewDidAppear = PublishSubject<Void>()
  let scrollToTop = PublishRelay<Void>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.tintColor = UIColor(named: "BlueTintColor")
    navigationItem.title = NSLocalizedString("default-status", comment: "Home")
    navigationItem.titleView = navBarTitleView
    
    configureCollectionView()
    configureDataSource()
    configureNavBarSubtitleView()
    
    let refresh = UIRefreshControl()
    collectionView?.refreshControl = refresh
    
    bindViewModel()
    bindUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.prefersLargeTitles = false
    if let refresh = collectionView.refreshControl,
      viewModel.isRefreshing.value {
        refresh.beginRefreshing()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    viewDidAppear.onNext(())
    viewDidAppear.onCompleted()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if let refresh = collectionView?.refreshControl {
        refresh.endRefreshing()
    }
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
      .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] indexPath in
        self.collectionView.deselectItem(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected
      .throttle(RxTimeInterval.milliseconds(500), scheduler: eventScheduler)
      .observeOn(eventScheduler)
      .subscribe(onNext: { [unowned self] indexPath in
        let selectedCell = self.currentSnapshot.sectionIdentifiers[indexPath.section].shops[indexPath.row]
        self.viewModel.selectedCell.accept((self, selectedCell))
      })
      .disposed(by: disposeBag)
  }
  
  private func bindUI() {
    if let refresh = collectionView.refreshControl {
      viewModel.updateRefreshingStatus
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
    
    viewModel.updatingTitle
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] event in
        switch event {
        case .default(let text):
          self?.navBarTitleView.setDefaultTitle(to: text)
          
        case .dowloading(let text):
          self?.navBarTitleView.setDownloadingTitle(to: text)
          
        case .downloaded(let text):
          self?.navBarTitleView.setDownloadedTitle(to: text)
          
        case .waitingForNetwork(let text):
          self?.navBarTitleView.setDownloadedTitle(to: text)
          
        case .error(let description, let text):
          self?.navBarTitleView.setErrorTitle(to: text)
          self?.navBarSubtitleView.promt.text = description
          UIView.animate(withDuration: 0.5) { [weak self] in
            self?.navBarSubtitleViewHeightConstraint.constant = 40
            self?.view.layoutIfNeeded()
          }
          return
        }
        
        UIView.animate(withDuration: 0.5) { [weak self] in
          self?.navBarSubtitleViewHeightConstraint.constant = 0
          self?.view.layoutIfNeeded()
        }
      })
      .disposed(by: disposeBag)
    
    viewDidAppear
      .take(1)
      .withLatestFrom(viewModel.showOnboarding)
      .filter { $0 }
      .map { _ in }
      .subscribeOn(defaultScheduler)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        let onboardingVC = OnboardingViewController.createVC()
        self?.present(onboardingVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    scrollToTop
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] vc in
        self?.collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
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
      
      if self.viewModel.advEnabled.value,
        self.viewModel.advSections.value.contains(sectionIndex) {
        return self.createAdvSection(layoutEnvironment)
      }
      
      switch sectionIndex {
      case 0:
        return self.createCardSection(layoutEnvironment)
      default:
        return self.createPlainSection(layoutEnvironment)
      }
    }
    
    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.interSectionSpacing = 15
    
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
    
    let groupFractionalWidth: CGFloat
    let groupFractionHeigh: CGFloat
    
    switch (layoutEnvironment.traitCollection.horizontalSizeClass, layoutEnvironment.traitCollection.verticalSizeClass) {
    case (.compact, .regular):
      groupFractionalWidth = CGFloat(0.44)
      groupFractionHeigh = CGFloat(0.42)
      
    case (.compact, .compact):
      groupFractionalWidth = CGFloat(0.25)
      groupFractionHeigh = CGFloat(0.7)
      
    case (.regular, .compact):
      groupFractionalWidth = CGFloat(0.3)
      groupFractionHeigh = CGFloat(0.8)
      
    case (.regular, .regular):
      groupFractionalWidth = CGFloat(0.35)
      groupFractionHeigh = CGFloat(0.42)
      
    default:
      groupFractionalWidth = CGFloat(0.45)
      groupFractionHeigh = CGFloat(0.42)
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
    
    let groupFractionalWidth: CGFloat
    let groupFractionHeigh: CGFloat
    
    switch (layoutEnvironment.traitCollection.horizontalSizeClass, layoutEnvironment.traitCollection.verticalSizeClass) {
    case (.compact, .regular):
      groupFractionalWidth = CGFloat(0.36)
      groupFractionHeigh = CGFloat(0.21)
      
    case (.compact, .compact):
      groupFractionalWidth = CGFloat(0.2)
      groupFractionHeigh = CGFloat(0.35)
      
    case (.regular, .compact):
      groupFractionalWidth = CGFloat(0.2)
      groupFractionHeigh = CGFloat(0.35)
      
    case (.regular, .regular):
      groupFractionalWidth = CGFloat(0.25)
      groupFractionHeigh = CGFloat(0.21)
      
    default:
      groupFractionalWidth = CGFloat(0.36)
      groupFractionHeigh = CGFloat(0.21)
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
    
    let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize,
                                                                         elementKind: HomeViewController.titleElementKind,
                                                                         alignment: .top)
    
    section.boundarySupplementaryItems = [titleSupplementary]
    
    return section
  }
  
  func createAdvSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupFractionalWidth: CGFloat
    let groupFractionHeigh: CGFloat
    
    switch (layoutEnvironment.traitCollection.horizontalSizeClass, layoutEnvironment.traitCollection.verticalSizeClass) {
    case (.compact, .regular):
      groupFractionalWidth = CGFloat(0.8)
      groupFractionHeigh = CGFloat(0.11)
      
    case (.compact, .compact):
      groupFractionalWidth = CGFloat(0.2)
      groupFractionHeigh = CGFloat(0.35)
      
    case (.regular, .compact):
      groupFractionalWidth = CGFloat(0.2)
      groupFractionHeigh = CGFloat(0.35)
      
    case (.regular, .regular):
      groupFractionalWidth = CGFloat(0.25)
      groupFractionHeigh = CGFloat(0.21)
      
    default:
      groupFractionalWidth = CGFloat(0.8)
      groupFractionHeigh = CGFloat(0.11)
    }
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                           heightDimension: .fractionalHeight(groupFractionHeigh))
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
    section.interGroupSpacing = 10
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
    
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
    collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
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
    
    collectionView.register(AdvertisingImageCollectionViewCell.self,
                            forCellWithReuseIdentifier: AdvertisingImageCollectionViewCell.reuseIdentifier)
    
    collectionView.register(TitleSupplementaryView.self,
                            forSupplementaryViewOfKind: HomeViewController.titleElementKind,
                            withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
  }
  
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource
      <ShopCategoryData, ShopData> (collectionView: collectionView) { [weak self] (collectionView: UICollectionView,
        indexPath: IndexPath,
        cellData: ShopData) -> UICollectionViewCell? in
        
        guard let self = self else { return nil }
        
        if cellData.name == "AdvertisingCell" {
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdvertisingImageCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as? AdvertisingImageCollectionViewCell else {
                                                                fatalError("Can't create new adv cell")
          }
          
          if let image = cellData.previewImage.value {
            cell.imageView.image = image
          } else {
            cell.imageView.backgroundColor = cellData.placeholderColor
            self.viewModel.setupAdvImage(for: cellData)
              .observeOn(MainScheduler.instance)
              .subscribe(onCompleted: {
                cell.imageView.image = cellData.previewImage.value
              })
              .disposed(by: cell.disposeBag)
          }
          
          return cell
        }
        
        switch indexPath.section {
        case 0:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCardCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as? HomeCardCollectionViewCell else {
                                                                fatalError("Can't create new cell")
          }
          
          if let image = cellData.previewImage.value {
            cell.imageView.image = image
          } else {
            cell.imageView.backgroundColor = cellData.placeholderColor
            self.viewModel.setupPreviewImage(for: cellData)
              .observeOn(MainScheduler.instance)
              .subscribe(onCompleted: {
                cell.imageView.image = cellData.previewImage.value
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
          
          if let image = cellData.previewImage.value {
            cell.imageView.image = image
          } else {
            cell.imageView.backgroundColor = cellData.placeholderColor
            self.viewModel.setupPreviewImage(for: cellData)
              .observeOn(MainScheduler.instance)
              .subscribe(onCompleted: {
                cell.imageView.image = cellData.previewImage.value
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
        let snapshot = self.currentSnapshot,
        let titleSupplementary = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                 withReuseIdentifier: TitleSupplementaryView.reuseIdentifier,
                                                                                 for: indexPath) as? TitleSupplementaryView else {
          return nil
      }
      
      let section = snapshot.sectionIdentifiers[indexPath.section]
      titleSupplementary.label.text = section.categoryName
      
      titleSupplementary.showMoreButton.sectionTitle = section.categoryName
      
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

  // MARK: - Animatable View Setup
extension HomeViewController {
  
  private func configureNavBarSubtitleView() {
    navBarSubtitleView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(navBarSubtitleView)
    
    navBarSubtitleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    navBarSubtitleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    navBarSubtitleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    
    navBarSubtitleViewHeightConstraint = navBarSubtitleView.heightAnchor.constraint(equalToConstant: 0)
    navBarSubtitleViewHeightConstraint.isActive = true
  }
}

  // MARK: - Scroll to Top Gesture
extension HomeViewController: ScrollToTopGestureProtocol {}
