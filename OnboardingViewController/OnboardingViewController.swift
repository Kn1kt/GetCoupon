//
//  OnboardingViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 05.07.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OnboardingViewController: UIViewController {
  
  @IBOutlet weak var pageControll: UIPageControl!
  @IBOutlet weak var nextLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var collectionView: UICollectionView!
  
  private let disposeBag = DisposeBag()
  private let defaultSheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  static func createVC() -> UIViewController {
    let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
    
    return storyboard.instantiateViewController(identifier: "OnboardingViewController")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.setCollectionViewLayout(createLayout(), animated: false)
    
    startButton.layer.cornerRadius = 8
    startButton.transform = CGAffineTransform(translationX: 0, y: startButton.bounds.height)
    
    bindUI()
  }
  
  private func createLayout() -> UICollectionViewLayout {
    let sectionProvider = { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
      guard let self = self else { return nil }
      
      return self.createPlaintSection(layoutEnvironment)
    }
    let config = UICollectionViewCompositionalLayoutConfiguration()
    
    let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider,
                                                     configuration: config)
    
    return layout
    
  }
  
  private func createPlaintSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalHeight(1.0))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging
    
    return section
  }
  
  private func bindUI() {
    skipButton.rx.tap
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    startButton.rx.tap
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    nextButton.rx.tap
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        let nextItem = self.pageControll.currentPage + 1
        
        if nextItem < self.pageControll.numberOfPages {
          self.collectionView.scrollToItem(at: IndexPath(row: nextItem, section: 0), at: .left, animated: true)
        }
        
      })
      .disposed(by: disposeBag)
    
    if let button = nextButton as? NextButton {
      button.isHiglightedSubject
        .subscribeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] isHighlighted in
          self?.nextLabel.isHighlighted = isHighlighted
        })
        .disposed(by: disposeBag)
    }
  }
  
}

extension OnboardingViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 4
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch indexPath.row {
    case 0:
      return collectionView.dequeueReusableCell(withReuseIdentifier: "FirstItemReuseIdentifier", for: indexPath)
    case 1:
      return collectionView.dequeueReusableCell(withReuseIdentifier: "SecondItemReuseIdentifier", for: indexPath)
    case 2:
      return collectionView.dequeueReusableCell(withReuseIdentifier: "ThirdItemReuseIdentifier", for: indexPath)
    case 3:
      return collectionView.dequeueReusableCell(withReuseIdentifier: "FourthItemReuseIdentifier", for: indexPath)
    default:
      fatalError("Overbound Rows")
    }
  }
}

extension OnboardingViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let indices = self.collectionView.indexPathsForVisibleItems
    
    if indices.count == 1,
      let index = indices.first?.row {
      self.pageControll.currentPage = index
      
      if index == self.pageControll.numberOfPages - 1 {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: { [weak self] in
          self?.nextLabel.alpha = 0
          self?.nextButton.alpha = 0
          self?.skipButton.alpha = 0
          self?.pageControll.alpha = 0
          self?.startButton.alpha = 1
          
          self?.startButton.transform = .identity
          })
      } else if startButton.transform == .identity {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: { [weak self] in
          self?.nextLabel.alpha = 1
          self?.nextButton.alpha = 1
          self?.skipButton.alpha = 1
          self?.pageControll.alpha = 1
          self?.startButton.alpha = 0
          
          let height = self?.startButton.bounds.height ?? 0
          self?.startButton.transform = CGAffineTransform(translationX: 0, y: height)
        })
      }
    }
  }
}
