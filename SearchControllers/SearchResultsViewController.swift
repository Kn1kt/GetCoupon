//
//  SearchReslutsViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 04.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchResultsViewController: UIViewController {

  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)

  let viewModel = SearchResultsViewModel()

  private var collectionView: UICollectionView! = nil
  private var suggestedSearchView: SuggestedSearchView!
  
  private var dataSource: UICollectionViewDiffableDataSource
    <ShopCategoryData, ShopData>! = nil
  private var currentSnapshot: NSDiffableDataSourceSnapshot
    <ShopCategoryData, ShopData>! = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.tintColor = UIColor(named: "BlueTintColor")

    configureCollectionView()
    configureDataSource()
    
//    configureSuggestedSearchView()
    
    bindViewModel()
    bindUI()
  }

  private func bindViewModel() {
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
    viewModel.currentCollection
      .drive(onNext: { [weak self] collection in
        self?.updateSnapshot(collection)
      })
      .disposed(by: disposeBag)
    
//    viewModel.showSuggestedSearches
//      .distinctUntilChanged()
//      .subscribeOn(MainScheduler.instance)
//      .observeOn(MainScheduler.instance)
//      .subscribe(onNext: { [weak self] isOn in
//        guard let self = self else { return }
//        self.suggestedSearchView.isHidden = !isOn
//        print(isOn)
//      })
//      .disposed(by: disposeBag)
  }
}

  // MARK: - Layouts
extension SearchResultsViewController {

  func createLayout() -> UICollectionViewLayout {

    let sectionProvider = { [weak self] (sectionIndex: Int,
      layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
      guard let self = self else { return nil }

      return self.createPlainSection(layoutEnvironment: layoutEnvironment)
    }

    let config = UICollectionViewCompositionalLayoutConfiguration()

    let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider,
                                                     configuration: config)

    return layout
  }

  func createPlainSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {

    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)

    var groupFractionHeigh: CGFloat! = nil

    switch (layoutEnvironment.traitCollection.horizontalSizeClass, layoutEnvironment.traitCollection.verticalSizeClass) {
    case (.compact, .regular):
      groupFractionHeigh = CGFloat(0.12)

    case (.compact, .compact):
      groupFractionHeigh = CGFloat(0.2)

    case (.regular, .compact):
      groupFractionHeigh = CGFloat(0.12)

    case (.regular, .regular):
      groupFractionHeigh = CGFloat(0.12)

    default:
      groupFractionHeigh = CGFloat(0.12)
    }

    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalHeight(groupFractionHeigh))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                   subitems: [item])


    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)

    return section
  }
}

// MARK: - Setup Collection View
extension SearchResultsViewController {

  func configureCollectionView() {
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())

    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .systemGroupedBackground
    collectionView.alwaysBounceVertical = true
    collectionView.keyboardDismissMode = .onDrag
    view.addSubview(collectionView)

    NSLayoutConstraint.activate([
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    collectionView.register(SearchPlainCollectionViewCell.self,
                            forCellWithReuseIdentifier: SearchPlainCollectionViewCell.reuseIdentifier)

  }
  
//  func configureSuggestedSearchView() {
//    suggestedSearchView = SuggestedSearchView(frame: view.frame, viewModel: viewModel)
//
//    suggestedSearchView.translatesAutoresizingMaskIntoConstraints = false
//    view.addSubview(suggestedSearchView)
//
//    NSLayoutConstraint.activate([
//      suggestedSearchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//      suggestedSearchView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//      suggestedSearchView.topAnchor.constraint(equalTo: view.topAnchor),
//      suggestedSearchView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//    ])
//  }
  
  private func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource
      <ShopCategoryData, ShopData> (collectionView: collectionView) { [weak self] (collectionView: UICollectionView,
        indexPath: IndexPath,
        cellData: ShopData) -> UICollectionViewCell? in

        guard let self = self else {
          return nil
        }


        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchPlainCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? SearchPlainCollectionViewCell else {
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

        self.updateBorder(for: cell, at: indexPath)

        return cell

    }

    currentSnapshot = NSDiffableDataSourceSnapshot
      <ShopCategoryData, ShopData>()

    dataSource.apply(currentSnapshot, animatingDifferences: false)
  }

  private func updateBorder(for cell: SearchPlainCollectionViewCell, at indexPath: IndexPath) {
    if indexPath.row == 0 && indexPath.row == self.currentSnapshot.numberOfItems - 1 {
      cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
      cell.contentView.layer.cornerRadius = 15
      cell.separatorView.isHidden = true

    } else if indexPath.row == 0 {
      cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
      cell.contentView.layer.cornerRadius = 15

    } else if indexPath.row == self.currentSnapshot.numberOfItems - 1 {
      cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
      cell.contentView.layer.cornerRadius = 15
      cell.separatorView.isHidden = true
    }
  }
}

// MARK: - Update Snapshot
extension SearchResultsViewController {

  func updateSnapshot(_ collection: ShopCategoryData) {
    currentSnapshot = NSDiffableDataSourceSnapshot
      <ShopCategoryData, ShopData>()

    currentSnapshot.appendSections([collection])
    currentSnapshot.appendItems(collection.shops)

    dataSource.apply(currentSnapshot, animatingDifferences: true)
  }
}

