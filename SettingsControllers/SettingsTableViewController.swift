//
//  SettingsTableViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 04.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsTableViewController: UITableViewController {
  
  private let disposeBag = DisposeBag()
  private let defaultSheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private let viewModel = SettingsViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.tintColor = UIColor(named: "BlueTintColor")
    
    bindViewModel()
    bindUI()
  }
  
  private func bindViewModel() {
    tableView.rx.itemSelected
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .filter { indexPath in
        if indexPath.section == 1, indexPath.row == 1 {
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
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 4
    case 1:
      return 3
    default:
      fatalError("Overbound Sections")
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionHeader(for: section)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let reuseIndentifer = cellReuseIdentifier(for: indexPath)
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIndentifer, for: indexPath)
    
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 0:
        return configurePushNotificationsCell(cell)
//      case 1:
//        return configureEmailNotificationsCell(cell)
      case 1:
        return configureForceUpdatingCell(cell)
      case 2:
        return configureClearCacheCell(cell)
      case 3:
        return configureSharePromoCell(cell)
      default:
        fatalError("Overbound Rows")
      }
    case 1:
      switch indexPath.row {
      case 0:
        return configureRateUsCell(cell)
      case 1:
        return configureTermsOfServiceCell(cell)
      case 2:
        return configureFeedbackCell(cell)
      case 3:
        return configureAboutCell(cell)
      default:
        fatalError("Overbound Rows")
      }
    default:
      fatalError("Overbound Sections")
    }
  }
  
  private func cellReuseIdentifier(for indexPath: IndexPath) -> String {
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 0, 1:
        return SettingsDoubleTextAndSwitchTableViewCell.reuseIdentifier
      case 3:
        return SettingsDoubleTextAndAccessoryTableViewCell.reuseIdentifier
      default:
        return SettingsTextAndAccessoryTableViewCell.reuseIdentifier
      }
      
    case 1:
      return SettingsTextAndAccessoryTableViewCell.reuseIdentifier
      
    default:
      fatalError("Overbound Sections")
    }
  }
  
  private func sectionHeader(for section: Int) -> String {
    switch section {
    case 0:
      return "Basic"
    case 1:
      return "Additional"
    default:
      fatalError("Overbound Sections")
    }
  }
}
  
  // MARK: - Configuring Cells
extension SettingsTableViewController {
  
  private func configurePushNotificationsCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsDoubleTextAndSwitchTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = "Push Notifications"
    cell.subtitleLabel.text = "Receive push notifications of new promo codes"
    
    viewModel.pushNotificationsSwitherShould
      .drive(onNext: { [weak self] isOn in
        cell.switcher.setOn(isOn, animated: true)
        self?.showPushDisabledAlert()
      })
      .disposed(by: cell.disposeBag)
    
    cell.switcher.isOn = viewModel.pushNotifications.value
    cell.switcher.rx.isOn
      .skip(1)
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: viewModel.pushNotifications)
      .disposed(by: cell.disposeBag)
    
    return cell
  }
  
//    private func configureEmailNotificationsCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
//      guard let cell = tableViewCell as? SettingsDoubleTextAndSwitchTableViewCell else {
//        return tableViewCell
//      }
//
//      cell.titleLabel.text = "Receive Email Notifications"
//      cell.subtitleLabel.text = "Every week you will receive an email with new promotional codes"
//
//      cell.switcher.isOn = viewModel.emailNotifications.value
//      cell.switcher.rx.isOn
//        .skip(1)
//        .filter { $0 }
//        .subscribeOn(eventScheduler)
//        .observeOn(MainScheduler.instance)
//        .subscribe(onNext: { [weak self] _ in
//          self?.showEmailAlert(switcher: cell.switcher)
//        })
//        .disposed(by: cell.disposeBag)
//
//      cell.switcher.rx.isOn
//        .skip(1)
//        .debounce(RxTimeInterval.milliseconds(500), scheduler: defaultSheduler)
//        .subscribeOn(defaultSheduler)
//        .observeOn(defaultSheduler)
//        .bind(to: viewModel.emailNotifications)
//        .disposed(by: cell.disposeBag)
//
//      return cell
//    }
  
  private func configureForceUpdatingCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsDoubleTextAndSwitchTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = "Force Catalog Updating"
    cell.subtitleLabel.text = "Update promo codes automatically every time you open the application"
    
    cell.switcher.isOn = viewModel.forceCatalogUpdating.value
    cell.switcher.rx.isOn
      .skip(1)
      .subscribeOn(eventScheduler)
      .observeOn(eventScheduler)
      .bind(to: viewModel.forceCatalogUpdating)
      .disposed(by: cell.disposeBag)
    
    return cell
  }
  
  private func configureClearCacheCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsTextAndAccessoryTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = "Clear Cache"
    
    return cell
  }
  
  private func configureSharePromoCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsDoubleTextAndAccessoryTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = "Share Your Promo Code"
    cell.subtitleLabel.text = "Found a new promo code?\nSend us and we will add it"
    
    return cell
  }
  
  private func configureRateUsCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsTextAndAccessoryTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = "Rate Us"
    
    return cell
  }
  
  private func configureTermsOfServiceCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsTextAndAccessoryTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = "Terms of Service"
    
    return cell
  }
  
  private func configureFeedbackCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsTextAndAccessoryTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = "Give Feedback"
    
    return cell
  }
  
  private func configureAboutCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsTextAndAccessoryTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = "About"
    
    return cell
  }
}

  // MARK: - Actions
extension SettingsTableViewController {
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 0, 1:
        return nil
      default:
        return indexPath
      }
      
    default:
      return indexPath
    }
  }
  
  private func showScreen(for indexPath: IndexPath) {
    
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 2:
        showClearCacheAlert()
      case 3:
        viewModel.showFeedbackVC.accept((self, FeedbackViewModel.FeedbackType.coupon))
      default:
        fatalError("Overbound Rows")
      }
    case 1:
      switch indexPath.row {
      case 0:
        showRateUsAlert()
      case 1:
        showTermsOfServiceScreen()
      case 2:
        viewModel.showFeedbackVC.accept((self, FeedbackViewModel.FeedbackType.general))
      default:
        fatalError("Overbound Rows")
      }
    default:
      fatalError("Overbound Sections")
    }
  }
  
  private func showTermsOfServiceScreen() {
    let storyboard = UIStoryboard(name: "SettingsTermsOfService", bundle: nil)
    let vc = storyboard.instantiateViewController(identifier: "SettingsTermsOfService")
    show(vc, sender: self)
  }
}

  // MARK: - Alerts
extension SettingsTableViewController {
  
  // MARK: - Push Alert
  private func showPushDisabledAlert() {
    let alertController = UIAlertController(title: "No Access to Notifications",
                                            message: "Please, allow notifications for GetCoupon app in settings.",
                                            preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(action)
    
    present(alertController, animated: true, completion: nil)
  }
  
  // MARK: - Email Alert
//  private func showEmailAlert(switcher: UISwitch) {
//    var disposeBag: DisposeBag? = DisposeBag()
//    weak var textBox: UITextField?
//    
//    let title = NSLocalizedString("Email Notifications", comment: "")
//    let message = NSLocalizedString("Enter email address for weekly notifications", comment: "")
//    let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
//    let otherButtonTitle = NSLocalizedString("OK", comment: "")
//    
//    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//    
//    let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { [weak self] _ in
//      print("The Email alert's cancel action occurred.")
//      self?.viewModel.emailNotifications.accept(false)
//      switcher.setOn(false, animated: true)
//      disposeBag = nil
//    }
//    
//    let acceptAction = UIAlertAction(title: otherButtonTitle, style: .default) { [weak self] _ in
//      print("The Email alert's other action occurred.")
//      
//      if let email = textBox?.text {
//        self?.viewModel.userEmail.accept(email)
//      }
//      disposeBag = nil
//    }
//    
//    alertController.addTextField { [weak self] textField in
//      guard let self = self else { return }
//      
//      textBox = textField
//      
//      textField.text = self.viewModel.userEmail.value
//      
//      textField.rx.text
//        .map {
//          guard let text = $0,
//            !text.isEmpty else { return false }
//          
//          if let index = text.firstIndex(of: "@") {
//            let suffix = text.suffix(from: index)
//            if let dotIndex = suffix.firstIndex(of: ".") {
//              let dotSuffix = suffix.suffix(from: dotIndex)
//              if dotSuffix.count > 2 {
//                return true
//              }
//            }
//          }
//          
//          return false
//        }
//        .subscribeOn(self.eventScheduler)
//        .observeOn(MainScheduler.instance)
//        .bind(to: acceptAction.rx.isEnabled)
//        .disposed(by: disposeBag!)
//        
//    }
//    
//    alertController.addAction(cancelAction)
//    alertController.addAction(acceptAction)
//    
//    present(alertController, animated: true, completion: nil)
//  }
  
  // MARK: - Cache Alert
  private func showClearCacheAlert() {
    let title = "Deleting Cached Images"
    let message = "Are u actually wanna delete all cached images"
    let cancelButtonTile = "Cancel"
    let destructiveButtonTitle = "Clear Cache"
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    let cancelAction = UIAlertAction(title: cancelButtonTile, style: .cancel) { _ in
      debugPrint("The cancel action occurred.")
    }
    let destructiveAction = UIAlertAction(title: destructiveButtonTitle, style: .destructive) { [weak self] _ in
      guard let self = self else { return }
      
      self.viewModel.clearCache.accept(())
      debugPrint("The destructive action occurred.")
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(destructiveAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  // MARK: - Rate Us Alert
  private func showRateUsAlert() {
    let alertController = UIAlertController(title: "Rate Our App",
                                            message: "Please leave a review about the application.\n(just placeholder)",
                                            preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(action)
    
    present(alertController, animated: true, completion: nil)
  }
}
