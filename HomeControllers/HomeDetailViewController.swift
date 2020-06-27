//
//  HomeDetailViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 22.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeDetailViewController: UIViewController {
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private var viewModel: HomeDetailViewModel!
  
  private let segmentedCell = ShopData(name: "segmented", shortDescription: "segmented")
  private let segmentedSection: ShopCategoryData = ShopCategoryData(categoryName: "segmented")
  
  private let searchCell = ShopData(name: "search", shortDescription: "search")
  private let searchSection: ShopCategoryData = ShopCategoryData(categoryName: "search")
  
  var collectionView: UICollectionView! = nil
  var dataSource: UICollectionViewDiffableDataSource
    <ShopCategoryData, ShopData>! = nil
  var currentSnapshot: NSDiffableDataSourceSnapshot
    <ShopCategoryData, ShopData>! = nil
  
  static func createWith(viewModel: HomeDetailViewModel) -> HomeDetailViewController {
    let vc = HomeDetailViewController()
    vc.viewModel = viewModel
    
    return vc
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = viewModel.currentTitle
    
    segmentedSection.shops.append(segmentedCell)
    searchSection.shops.append(searchCell)
    
    configureCollectionView()
    configureDataSource()
    
    bindViewModel()
    bindUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.prefersLargeTitles = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    viewModel.controllerWillDisappear.accept(())
  }
  
  private func bindUI() {
    viewModel.currentSection
      .drive(onNext: { [weak self] section in
        self?.updateSnapshot(section)
      })
      .disposed(by: disposeBag)
    
    viewModel.favoritesUpdates
      .emit(onNext: { [weak self] in
        self?.updateVisibleItems()
      })
      .disposed(by: disposeBag)
  }
  
  private func bindViewModel() {
    collectionView.rx.itemSelected
      .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] indexPath in
        self.collectionView.deselectItem(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected
      .throttle(RxTimeInterval.milliseconds(500), scheduler: defaultScheduler)
      .map { _ in () }
      .subscribeOn(defaultScheduler)
      .observeOn(defaultScheduler)
      .bind(to: viewModel.controllerWillDisappear)
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected
      .throttle(RxTimeInterval.milliseconds(500), scheduler: eventScheduler)
      .map { [unowned self] indexPath in
        let selectedShop = self.currentSnapshot.sectionIdentifiers[indexPath.section].shops[indexPath.row]
        return (self, selectedShop)
      }
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: viewModel.showShopVC)
      .disposed(by: disposeBag)
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
        return self.createSearchSection(layoutEnvironment)
      case 1:
        return self.createSegmentedControlSection(layoutEnvironment)
      default:
        return self.createPlainSection(layoutEnvironment)
      }
      
    }
    
    let config = UICollectionViewCompositionalLayoutConfiguration()
    
    let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider,
                                                     configuration: config)
    
    return layout
  }
  
  func createSearchSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
    
    return section
  }
  
  func createSegmentedControlSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    
    section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 15, trailing: 15)
    
    return section
  }
  
  func createPlainSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
    
    var groupFractionHeigh: CGFloat! = nil
    
    switch (layoutEnvironment.traitCollection.horizontalSizeClass, layoutEnvironment.traitCollection.verticalSizeClass) {
    case (.compact, .regular):
      groupFractionHeigh = CGFloat(0.15)
      
    case (.compact, .compact):
      groupFractionHeigh = CGFloat(0.3)
      
    case (.regular, .compact):
      groupFractionHeigh = CGFloat(0.15)
      
    case (.regular, .regular):
      groupFractionHeigh = CGFloat(0.15)
      
    default:
      groupFractionHeigh = CGFloat(0.15)
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
extension HomeDetailViewController {
  
  func configureCollectionView() {
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .systemGroupedBackground
    collectionView.alwaysBounceVertical = true
    collectionView.keyboardDismissMode = .onDrag
    view.addSubview(collectionView)
    
    collectionView.delegate = self
    
    NSLayoutConstraint.activate([
      
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      
    ])
    
    
    collectionView.register(HomeDetailCollectionViewCell.self,
                            forCellWithReuseIdentifier: HomeDetailCollectionViewCell.reuseIdentifier)
    
    collectionView.register(HomeDetailSegmentedControlCollectionViewCell.self,
                            forCellWithReuseIdentifier: HomeDetailSegmentedControlCollectionViewCell.reuseIdentifier)
    
    collectionView.register(SearchCollectionViewCell.self,
                            forCellWithReuseIdentifier: SearchCollectionViewCell.reuseIdentidier)
  }
  
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource
      <ShopCategoryData, ShopData> (collectionView: collectionView) { [weak self] (collectionView: UICollectionView,
        indexPath: IndexPath,
        cellData: ShopData) -> UICollectionViewCell? in
        guard let self = self else {
          return nil
        }
        
        switch indexPath.section {
        case 0:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.reuseIdentidier,
                                                              for: indexPath) as? SearchCollectionViewCell else {
                                                                fatalError("Can't create new cell")
          }
          cell.searchBar.delegate = self
          cell.searchBar.searchTextField.delegate = self
          
          return cell
          
        case 1:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:        HomeDetailSegmentedControlCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as? HomeDetailSegmentedControlCollectionViewCell else {
                                                                fatalError("Can't create new cell")
          }
          
          self.viewModel.currentSection
            .map { section in
              return "\(section.shops.count) " + NSLocalizedString("shops", comment: "Shops")
          }
          .drive(cell.countLabel.rx.text)
          .disposed(by: cell.disposeBag)
          
          cell.segmentedControl.selectedSegmentIndex = self.viewModel.segmentIndex.value
          
            cell.segmentedControl.rx.controlEvent(.valueChanged)
              .throttle(RxTimeInterval.milliseconds(500),
                        scheduler: MainScheduler.instance)
              .map { cell.segmentedControl.selectedSegmentIndex }
              .subscribeOn(MainScheduler.instance)
              .observeOn(self.eventScheduler)
              .bind(to: self.viewModel.segmentIndex)
              .disposed(by: cell.disposeBag)
          
          return cell
          
        default:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeDetailCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as? HomeDetailCollectionViewCell else {
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
          
          self.viewModel.isUpdatingData
            .drive(onNext: { isUpdating in
              if isUpdating {
                cell.addToFavoritesButton.checkbox.alpha = 0.5
                cell.addToFavoritesButton.isEnabled = false
              } else {
                cell.addToFavoritesButton.checkbox.alpha = 1
                cell.addToFavoritesButton.isEnabled = true
              }
            })
            .disposed(by: cell.disposeBag)
          
          cell.addToFavoritesButton.checkbox.isHighlighted = cellData.isFavorite
          cell.addToFavoritesButton.cell = cellData
          
          self.updateBorder(for: cell, at: indexPath)
          
          cell.addToFavoritesButton.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
              self.viewModel.updateFavorites(cell.addToFavoritesButton)
              UIView.animate(withDuration: 0.15) {
                cell.addToFavoritesButton.checkbox.isHighlighted = cellData.isFavorite
              }
            })
            .disposed(by: cell.disposeBag)
          
          cell.addToFavoritesButton.rx.tap
            .map { cellData }
            .throttle(RxTimeInterval.milliseconds(500),
                      scheduler: self.defaultScheduler)
            .subscribeOn(self.defaultScheduler)
            .observeOn(self.defaultScheduler)
            .bind(to: self.viewModel.editedShops)
            .disposed(by: cell.disposeBag)
          
          return cell
        }
        
    }
    
    currentSnapshot = NSDiffableDataSourceSnapshot
      <ShopCategoryData, ShopData>()
    
    currentSnapshot.appendSections([searchSection])
    currentSnapshot.appendItems(searchSection.shops)
    
    currentSnapshot.appendSections([segmentedSection])
    currentSnapshot.appendItems(segmentedSection.shops)
    
    dataSource.apply(currentSnapshot, animatingDifferences: false)
  }
  
  private func updateBorder(for cell: HomeDetailCollectionViewCell, at indexPath: IndexPath) {
    if indexPath.row == 0 && indexPath.row == self.currentSnapshot.numberOfItems - 3 {
      cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
      cell.layer.cornerRadius = 15
      cell.separatorView.isHidden = true
      
    } else if indexPath.row == 0 {
      cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
      cell.layer.cornerRadius = 15
      
    } else if indexPath.row == self.currentSnapshot.numberOfItems - 3 {
      cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
      cell.layer.cornerRadius = 15
      cell.separatorView.isHidden = true
    }
  }
}

  // MARK: - Interaction
extension HomeDetailViewController {
  
  func updateSnapshot(_ section: ShopCategoryData) {
    currentSnapshot = NSDiffableDataSourceSnapshot
      <ShopCategoryData, ShopData>()
    
    currentSnapshot.appendSections([searchSection])
    currentSnapshot.appendItems(searchSection.shops)
    
    currentSnapshot.appendSections([segmentedSection])
    currentSnapshot.appendItems(segmentedSection.shops)
    
    currentSnapshot.appendSections([section])
    currentSnapshot.appendItems(section.shops)

    dataSource.apply(currentSnapshot, animatingDifferences: true)
  }
  
  func updateVisibleItems() {
    let indexPaths = collectionView.indexPathsForVisibleItems
    
    indexPaths.forEach { indexPath in
      guard let cell = collectionView.cellForItem(at: indexPath) as? HomeDetailCollectionViewCell,
        let cellData = dataSource.itemIdentifier(for: indexPath) else {
          return
      }
      
      UIView.animate(withDuration: 0.3) {
        cell.addToFavoritesButton.checkbox.isHighlighted = cellData.isFavorite
      }
    }
  }
}

  // MARK: - SerachBarDelegate
extension HomeDetailViewController: UISearchBarDelegate, UITextFieldDelegate {
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.searchText.accept(searchText)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}

  // MARK: - UICollectionViewDelegate
extension HomeDetailViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    switch indexPath.section {
    case 0:
      return false
    case 1:
      return false
    default:
      return true
    }
  }
}
