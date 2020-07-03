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
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private var viewModel: ShopViewModel!
  
  private let dateFormatter = DateFormatter()
  private let headerImageView = UIImageView()
  private let logoView = LogoWithFavoritesButton()
  private let cornedTopView = UIView()
  
  private let navBarIsHidden = BehaviorRelay<Bool>(value: true)
  
  private let overlayView = UIView()
  private let popupView = CouponPopupView()
  
  private let label = UILabel()
  
  private lazy var navBarPlaceholder: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
    let view = UIVisualEffectView(effect: blurEffect)
    view.alpha = 0
    return view
  }()
  
  private lazy var navBarShadow: UIView = {
    let view = UIView()
    view.backgroundColor = .systemGray2
    view.alpha = 0
    return view
  }()
  
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
    
    configureCollectionView()
    configureDataSource()
    
    layoutPopupView()
    tapRecognizer.addTarget(self, action: #selector(closePopupView))
    tapRecognizer.delegate = self
    overlayView.addGestureRecognizer(tapRecognizer)
    
    panRecognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
    panRecognizer.delegate = self
    popupView.addGestureRecognizer(panRecognizer)
    
    let recognizer = UIPanGestureRecognizer()
    recognizer.delegate = self
    view.addGestureRecognizer(recognizer)
    
    layoutNavBarPlaceholder()
    
    bindViewModel()
    bindUI()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    viewModel.controllerWillDisappear.accept(())
  }
  
  private func bindUI() {
    collectionView.rx.itemSelected
      .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] indexPath in
        self.collectionView.deselectItem(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] indexPath in
        let shop = self.viewModel.currentShop
        self.setupPopupView(shopName: shop.name,
                            promocode: shop.promoCodes[indexPath.row])
        self.showPopupView()
      })
      .disposed(by: disposeBag)
    
    popupView.exitButton.rx.tap
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] _ in
        self.closePopupView()
      })
      .disposed(by: disposeBag)
    
    popupView.shareButton.rx.tap
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] _ in
        guard let promoCode = self.popupView.promocodeView.promocodeLabel.text,
              let coupon = self.viewModel.currentShop.promoCodes.first(where: { $0.coupon == promoCode }) else {
          return
        }
        self.showShareCouponVC(shop: self.viewModel.currentShop, coupon: coupon)
      })
      .disposed(by: disposeBag)
    
    viewModel.favoriteButtonEnabled
      .drive(logoView.favoritesButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    viewModel.favoriteButtonEnabled
      .filter { !$0 }
      .map { _ in CGFloat(0.5) }
      .drive(logoView.favoritesButton.checkbox.rx.alpha)
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
    logoView.favoritesButton.checkbox.isHighlighted = shop.isFavorite
  }
  
  private func configureNavigationController(_ nc: UINavigationController?) {
    nc?.navigationBar.prefersLargeTitles = false
    nc?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    nc?.navigationBar.shadowImage = UIImage()
    nc?.navigationBar.isTranslucent = true
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "xmark-gray"),
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(dismissVC))
    
    navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "BlueTintColor")
    
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    label.text = self.viewModel.currentShop.name
    label.alpha = 0
    navigationItem.titleView = label
  }
  
  @objc private func dismissVC() {
    self.dismiss(animated: true)
  }
  
  // MARK: - Popup Animations
  private var bottomPopupView = NSLayoutConstraint()
  
  private var popupOffset: CGFloat {
    return popupView.bounds.height
  }
  
  /// The current state of the animation. This variable is changed only when an animation completes.
  private var currentState: State = .closed {
    willSet {
      if newValue == .closed {
        popupView.promocodeView.stopAnimating()
      }
    }
  }
  
  /// All of the currently running animators.
  private var runningAnimators = [UIViewPropertyAnimator]()
  
  /// The progress of each animator. This array is parallel to the `runningAnimators` array.
  private var animationProgress = [CGFloat]()
  
  private let panRecognizer = UIPanGestureRecognizer()
  private let tapRecognizer = UITapGestureRecognizer()
  
  /// Animates the transition, if the animation is not already running.
  private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
    
    // ensure that the animators array is empty (which implies new animations need to be created)
    guard runningAnimators.isEmpty else { return }
    
    // an animator for the transition
    let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: { [weak self] in
      guard let self = self else { return }
      switch state {
      case .open:
        self.bottomPopupView.constant = 0
        self.popupView.layer.cornerRadius = 35
        self.overlayView.alpha = 0.5
        
      case .closed:
        self.bottomPopupView.constant = self.popupView.bounds.height
        self.popupView.layer.cornerRadius = 0
        self.overlayView.alpha = 0
        
        self.popupView.textSnapshot = self.popupView.textView.snapshotView(afterScreenUpdates: true)
        self.popupView.snapshotPlace.addSubview(self.popupView.textSnapshot!)
        self.popupView.textView.isHidden = true
      }
      
      self.view.layoutIfNeeded()
      self.popupView.textView.selectedRange = NSRange()
    })
    
    // the transition completion block
    transitionAnimator.addCompletion { position in
      self.popupView.textView.isHidden = false
      self.popupView.textSnapshot?.removeFromSuperview()
      self.popupView.textSnapshot = nil
      
      // update the state
      switch position {
      case .start:
        self.currentState = state.opposite
      case .end:
        self.currentState = state
      case .current:
        ()
      @unknown default:
        fatalError()
      }
      
      // manually reset the constraint positions
      switch self.currentState {
      case .open:
        self.bottomPopupView.constant = 0
      case .closed:
        self.bottomPopupView.constant = self.popupView.bounds.height
      }
      
      // remove all running animators
      self.runningAnimators.removeAll()
    }
    
    // start all animators
    transitionAnimator.startAnimation()
    
    // keep track of all running animators
    runningAnimators.append(transitionAnimator)
  }
  
  @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer) {
    switch recognizer.state {
    case .began:
      // start the animations
      animateTransitionIfNeeded(to: currentState.opposite, duration: 0.5)
      
      // pause all animations, since the next event may be a pan changed
      runningAnimators.forEach { $0.pauseAnimation() }
      
      // keep track of each animator's progress
      animationProgress = runningAnimators.map { $0.fractionComplete }
      
    case .changed:
      guard !runningAnimators.isEmpty else { return }
      // variable setup
      let translation = recognizer.translation(in: popupView)
      var fraction = -translation.y / popupOffset
      
      
      
      // adjust the fraction for the current state and reversed state
      if currentState == .open { fraction *= -1 }
      if runningAnimators[0].isReversed { fraction *= -1 }
      
      // apply the new fraction
      for (index, animator) in runningAnimators.enumerated() {
        animator.fractionComplete = fraction + animationProgress[index]
      }
      
    case .ended:
      guard !runningAnimators.isEmpty else { return }

      // variable setup
      let yVelocity = recognizer.velocity(in: popupView).y
      let shouldClose = yVelocity > 0
      // if there is no motion, continue all animations and exit early
      if yVelocity == 0 {
        runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
        break
      }
      
      // reverse the animations based on their current state and pan motion
      switch currentState {
      case .open:
        if !shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
        if shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
      case .closed:
        if shouldClose && !runningAnimators[0].isReversed {
          runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
        if !shouldClose && runningAnimators[0].isReversed {
          runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
      }
      
      // continue all animations
      runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }

    default:
      ()
    }
  }
  
  private func showPopupView() {
    animateTransitionIfNeeded(to: .open, duration: 0.5)
  }
  
  @objc private func closePopupView() {
    animateTransitionIfNeeded(to: .closed, duration: 0.5)
  }
  
}

  // MARK: - State
private enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

  // MARK: - Popup Layouts
extension ShopViewController {
  
  private func layoutPopupView() {
    overlayView.backgroundColor = .black
    overlayView.alpha = 0
    
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(overlayView)
    overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    overlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    
    popupView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(popupView)
    popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    popupView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.85).isActive = true
    
    bottomPopupView = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.bounds.height)
    bottomPopupView.isActive = true
  }
  
  private func layoutNavBarPlaceholder() {
    guard let navBarHeight = navigationController?.navigationBar.bounds.height else {
      return
    }
    
    navBarPlaceholder.translatesAutoresizingMaskIntoConstraints = false
    navBarShadow.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(navBarPlaceholder)
    view.addSubview(navBarShadow)
    
    NSLayoutConstraint.activate([
      navBarPlaceholder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      navBarPlaceholder.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      navBarPlaceholder.topAnchor.constraint(equalTo: view.topAnchor),
      navBarPlaceholder.heightAnchor.constraint(equalToConstant: navBarHeight),
      
      navBarShadow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      navBarShadow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      navBarShadow.topAnchor.constraint(equalTo: navBarPlaceholder.bottomAnchor),
      navBarShadow.heightAnchor.constraint(equalToConstant: 0.3)
    ])
  }
  
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
                                          heightDimension: .estimated(100))
    
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .estimated(100))
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                   subitems: [item])
    
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 40, leading: 10, bottom: 10, trailing: 10)
    
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
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
    
    return section
  }
  
  func createPlainSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15)
    
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
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    return section
  }
}

  // MARK: - Setup Collection View
extension ShopViewController {
  
  func configureCollectionView() {
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    collectionView.backgroundColor = .systemGroupedBackground
    collectionView.alwaysBounceVertical = true
    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(top: 250, left: 0, bottom: 0, right: 0)
    view.addSubview(collectionView)
    
    //  Setup header image
    headerImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200)
    headerImageView.backgroundColor = .systemGray3
    
    headerImageView.contentMode = .scaleAspectFill
    headerImageView.clipsToBounds = true
    headerImageView.backgroundColor = viewModel.currentShop.placeholderColor
    view.addSubview(headerImageView)
    
    cornedTopView.frame = CGRect(x: 0, y: collectionView.contentInset.top, width: UIScreen.main.bounds.size.width, height: 70)
    cornedTopView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    cornedTopView.layer.cornerRadius = 35
    cornedTopView.backgroundColor = .systemGroupedBackground
    cornedTopView.isUserInteractionEnabled = false
    
    view.addSubview(cornedTopView)
    
    logoView.frame = CGRect(x: view.center.x - 70,
                            y: 100,
                            width: 140,
                            height: 140)
    logoView.layoutIfNeeded()
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
          self.navBarIsHidden
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { isHidden in
              UIView.animate(withDuration: 0.3) {
                if isHidden {
                  cell.titleLabel.alpha = 1
                } else {
                  cell.titleLabel.alpha = 0
                }
              }
            })
            .disposed(by: cell.disposeBag)
          
          cell.subtitleLabel.text = self.viewModel.currentShop.description
          
          return cell
          
        case 1:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopDetailTitleCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as? ShopDetailTitleCollectionViewCell else {
                                                                fatalError("Can't create new cell")
          }
          
          let couponsCount = self.viewModel.currentShop.promoCodes.count
          cell.couponsCount.imageDescription.text = "\(couponsCount) " + NSLocalizedString("coupons", comment: "Coupons")
          
          cell.couponsCount.button.rx.tap
          .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
          .subscribeOn(MainScheduler.instance)
          .observeOn(MainScheduler.instance)
          .subscribe(onNext: { [unowned self] in
            guard couponsCount > 0 else { return }
            
            if couponsCount < 5 {
              let indexPath = IndexPath(row: couponsCount - 1, section: 2)
              self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
              
            } else {
              guard let titleSize = self.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))?.bounds.height,
                let segmentSize = self.collectionView.cellForItem(at: IndexPath(row: 0, section: 1))?.bounds.height,
                let navBarHeight = self.navigationController?.navigationBar.bounds.height else {
                  return
              }
              
              // 60 - it's sum of spasing between sections
              let yPosition = titleSize + segmentSize + 60
              let height = self.collectionView.bounds.height - self.collectionView.layoutMargins.bottom - navBarHeight
              
              self.collectionView.scrollRectToVisible(CGRect(x: 0, y: yPosition, width: 1, height: height), animated: true)
            }
          })
          .disposed(by: cell.disposeBag)
          
          cell.website.button.rx.tap
            .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
              self?.showWebsiteAlert()
            })
            .disposed(by: cell.disposeBag)
          
          cell.share.button.rx.tap
            .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
              self.showShareCouponVC(shop: self.viewModel.currentShop, coupon: nil)
            })
            .disposed(by: cell.disposeBag)
          
          return cell
          
        default:
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopPlainCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as? ShopPlainCollectionViewCell else {
                                                                fatalError("Can't create new cell")
          }
          
          cell.imageView.backgroundColor = self.viewModel.currentShop.placeholderColor
          cell.imageView.image =  self.viewModel.currentShop.previewImage.value
          
          cell.subtitleLabel.text = cellData.description
          cell.promocodeView.promocodeLabel.text = cellData.coupon
          
          if cellData.addingDate > Date(timeIntervalSinceNow: 0) {
            cell.addingDateLabel.text = NSLocalizedString("pinned", comment: "PINNED")
          } else {
//            cell.addingDateLabel.text = NSLocalizedString("posted", comment: "Posted") + ": " + self.dateFormatter.string(from: cellData.addingDate)
            let date = Int((abs(cellData.addingDate.timeIntervalSinceNow) / 60 / 60 / 24).rounded(.up))
            cell.addingDateLabel.text = NSLocalizedString("posted", comment: "Posted") + ": " + "\(date)" + NSLocalizedString("d", comment: "day")
          }
          
          cell.estimatedDateLabel.text = NSLocalizedString("expire", comment: "Expire") + ": " + self.dateFormatter.string(from: cellData.estimatedDate).dropLast(5)
          
          return cell
        }
    }
    
    currentSnapshot = NSDiffableDataSourceSnapshot
      <ShopData, PromoCodeData>()
    
    currentSnapshot.appendSections([titleSection])
    currentSnapshot.appendItems(titleSection.promoCodes)
    
    currentSnapshot.appendSections([detailTitleSection])
    currentSnapshot.appendItems(detailTitleSection.promoCodes)
    
    dataSource.apply(currentSnapshot, animatingDifferences: false)
  }
  
  
}

  // MARK: - Interaction
extension ShopViewController {
  
  private func updateSnapshot(_ shop: ShopData) {
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
  
  private func showShareCouponVC(shop: ShopData, coupon: PromoCodeData?) {
    let promoString = viewModel.buildShareText(for: shop, coupon: coupon)
    print(promoString)
    let activityViewController = UIActivityViewController(activityItems: [promoString], applicationActivities: nil)

    // This lines is for the popover you need to show in iPad
    activityViewController.popoverPresentationController?.sourceView = (popupView.shareButton)

    // This line remove the arrow of the popover to show in iPad
    activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
    activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

    // Anything you want to exclude
    activityViewController.excludedActivityTypes = [
      .saveToCameraRoll
    ]

    self.present(activityViewController, animated: true, completion: nil)
  }
  
  private func showWebsiteAlert() {
    let title = NSLocalizedString("shop-website-alert-title", comment: "Shop Website")
    let message = NSLocalizedString("shop-website-alert-subtitle", comment: "This store’s website will open.")
    let cancelButtonTitle = NSLocalizedString("cancel", comment: "Cancel")
    let okButtonTitle = NSLocalizedString("open", comment: "Open")
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
      debugPrint("The cancel action occurred.")
    }
    
    let openAction = UIAlertAction(title: okButtonTitle, style: .default) { [weak self] _ in
      guard let self = self else { return }
      
      self.viewModel.websiteButton.accept(())
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(openAction)
    
    present(alertController, animated: true, completion: nil)
  }
}

  //MARK: - Custom Header
extension ShopViewController: UICollectionViewDelegate {
  
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
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let y = -scrollView.contentOffset.y
    let height = min(max(y, 0), UIScreen.main.bounds.size.height)
    
    if let navBar = navigationController?.navigationBar {
      // Point Of Fade is negative, so need to subtract this
      let alpha = 1 - max(min(y, 250), 0) / 250
      
      // Update placeholder
      if navBar.backgroundImage(for: .default) != nil {
        navBarPlaceholder.alpha = alpha
        navBarShadow.alpha = alpha
      }
      
      // Swap placeholder to navigation bar or vice versa
      if self.label.alpha == 0 && y < 0 {
        navBarIsHidden.accept(false)
        
        if label.frame.minY == 0 {
          label.layer.position = CGPoint(x: label.layer.position.x,
                                         y: label.layer.position.y + label.bounds.height / 2)
        }
        
        UIView.animate(withDuration: 0.3) {
          self.label.alpha = 1
          self.label.layer.position = CGPoint(x: self.label.layer.position.x,
                                                y: self.label.layer.position.y - self.label.bounds.height / 2)
        }
        
      } else if self.label.alpha == 1 && y > 0 {
        navBarIsHidden.accept(true)
        
        UIView.animate(withDuration: 0.3) {
          self.label.alpha = 0
          self.label.layer.position = CGPoint(x: self.label.layer.position.x,
                                              y: self.label.layer.position.y + self.label.bounds.height / 2)
        }
      }
    }
    
    cornedTopView.layer.position = CGPoint(x: cornedTopView.layer.position.x, y: y - 10)
    logoView.layer.position = CGPoint(x: logoView.layer.position.x, y: y - 50)
    headerImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
  }
}

  // MARK: - Actions
extension ShopViewController {
  
  func updateVisibleItems(shop: ShopData) {
    let indexPaths = collectionView.indexPathsForVisibleItems

    indexPaths.forEach { indexPath in
      guard let cell = collectionView.cellForItem(at: indexPath) as? ShopPlainCollectionViewCell else {
        return
      }

      cell.imageView.image = shop.previewImage.value
    }
  }
}

  // MARK: - Setup Images
extension ShopViewController {
  
  private func updateImages(shop: ShopData) {
    if let headerImage = shop.image.value {
      headerImageView.image = headerImage
    } else {
      headerImageView.image = shop.previewImage.value
      headerImageView.alpha = 0.3
      viewModel.setupImage(for: shop)
        .observeOn(MainScheduler.instance)
        .subscribe(onCompleted: {
          UIView.animate(withDuration: 1) {
            if let image = shop.image.value {
              self.headerImageView.alpha = 0.1
              self.headerImageView.image = image
              self.headerImageView.alpha = 1
            }
          }
        })
        .disposed(by: disposeBag)
    }
    
    if let logoImage = shop.previewImage.value {
      logoView.imageView.image = logoImage
    } else {
      viewModel.setupPreviewImage(for: shop)
        .observeOn(MainScheduler.instance)
        .subscribe(onCompleted: {
          self.logoView.imageView.image = shop.previewImage.value
          self.updateVisibleItems(shop: shop)
        })
        .disposed(by: disposeBag)
    }
  }
}

  // MARK: - Setup Coupon Popup View
extension ShopViewController {
  
  private func setupPopupView(shopName: String, promocode: PromoCodeData) {
    popupView.titleLabel.text = shopName
    popupView.textView.text = promocode.description
    
    popupView.promocodeView.promocodeLabel.text = promocode.coupon
    popupView.expirationDateLabel.text = NSLocalizedString("exprire-at", comment: "Expire at") + " " + dateFormatter.string(from: promocode.estimatedDate)
  }
}

  // MARK: - Tap To Close Coupon View
extension ShopViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if gestureRecognizer == panRecognizer {
      return currentState == .open
    }
    
    if gestureRecognizer == tapRecognizer {
      return currentState == .open
    }
    
    if currentState == .open || !runningAnimators.isEmpty {
      return true
    }
    
    return false
  }
}
