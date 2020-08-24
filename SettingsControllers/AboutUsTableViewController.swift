//
//  AboutUsTableViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 22.08.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import StoreKit
import RxSwift
import RxCocoa

class AboutUsTableViewController: UITableViewController {
  
  static func createWith(viewModel: SettingsViewModel) -> UIViewController {
    let storyboard = UIStoryboard(name: "SettingsAboutUsScreen", bundle: nil)
    guard let vc = storyboard.instantiateViewController(identifier: "SettingsAboutUs") as? AboutUsTableViewController else {
      fatalError("NoFeedbackVC")
    }
    
    vc.viewModel = viewModel
    return vc
  }
  
  private let disposeBag = DisposeBag()
  private let defaultSheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private var viewModel: SettingsViewModel!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = NSLocalizedString("about", comment: "About")
    navigationItem.largeTitleDisplayMode = .never
    
    bindViewModel()
    bindUI()
  }
  
  private func bindViewModel() {
    tableView.rx.itemSelected
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .filter { indexPath in
        if indexPath.section == 0, indexPath.row == 3 {
          return false
        }
        
        return true
      }
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] indexPath in
        self.tableView.deselectRow(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] indexPath in
        self.showScreen(for: indexPath)
      })
      .disposed(by: disposeBag)
  }
  
  private func bindUI() {
  }
  
  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let reuseIndentifer = cellReuseIdentifier(for: indexPath)
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIndentifer, for: indexPath)
    switch indexPath.row {
    case 0:
      return configureLogoCell(cell)
    case 1:
      return configureFeedbackCell(cell)
    case 2:
      return configureRateUsCell(cell)
    case 3:
      return configureTermsOfServiceCell(cell)
    case 4:
      return configureWhatNewCell(cell)
    default:
      return cell
    }
  }
  
  private func cellReuseIdentifier(for indexPath: IndexPath) -> String {
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 0:
        return AboutLogoPreviewTableViewCell.reuseIdentifier
      default:
        return SettingsTextAndAccessoryTableViewCell.reuseIdentifier
      }
      
    default:
      fatalError("Overbound Sections")
    }
  }
}
  // MARK: - Configuring Cells
extension AboutUsTableViewController {
  
  private func configureLogoCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? AboutLogoPreviewTableViewCell else {
      return tableViewCell
    }
    
    return cell
  }

  private func configureFeedbackCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsTextAndAccessoryTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = NSLocalizedString("give-feedback-title", comment: "Give Feedback")
    
    return cell
  }
  
  private func configureRateUsCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsTextAndAccessoryTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = NSLocalizedString("rate-us-title", comment: "Rate Us")
    
    return cell
  }
  
  private func configureTermsOfServiceCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsTextAndAccessoryTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = NSLocalizedString("terms-of-service-title", comment: "Terms of Service")
    
    return cell
  }
  
  private func configureWhatNewCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsTextAndAccessoryTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = NSLocalizedString("what-new", comment: "What's New?")
    
    return cell
  }
}

  // MARK: - Actions
extension AboutUsTableViewController {
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    
    if indexPath.row == 0 {
      return nil
    }
    
    return indexPath
  }
  
  private func showScreen(for indexPath: IndexPath) {
    switch indexPath.row {
    case 1:
      viewModel.showFeedbackVC.accept((self, FeedbackViewModel.FeedbackType.general))
    case 2:
      showRateUsAlert()
    case 3:
      showTermsOfServiceScreen()
    case 4:
      showOnboardingScreen()
    default:
      fatalError("Overbound Actions")
    }
  }
  
  // MARK: - Screens
  private func showOnboardingScreen() {
    let onboardingVC = OnboardingViewController.createVC()
    present(onboardingVC, animated: true)
  }
  
  private func showTermsOfServiceScreen() {
    let storyboard = UIStoryboard(name: "SettingsTermsOfService", bundle: nil)
    let vc = storyboard.instantiateViewController(identifier: "SettingsTermsOfService")
    show(vc, sender: self)
  }
  
  private func showRateUsAlert() {
    SKStoreReviewController.requestReview()
  }
}
