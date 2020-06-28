//
//  SettingsTableViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 04.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import MessageUI
import RxSwift
import RxCocoa

class SettingsTableViewController: UITableViewController {
  
  private let disposeBag = DisposeBag()
  private let defaultSheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private let viewModel = SettingsViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = NSLocalizedString("settings", comment: "Settings")
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
      return 3
    case 1:
      return 4
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
      case 1:
        return configureClearCacheCell(cell)
      case 2:
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
        return configureContactUsCell(cell)
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
      case 0:
        return SettingsDoubleTextAndSwitchTableViewCell.reuseIdentifier
      case 2:
        return SettingsDoubleTextAndAccessoryTableViewCell.reuseIdentifier
      default:
        return SettingsTextAndAccessoryTableViewCell.reuseIdentifier
      }
      
    case 1:
      switch indexPath.row {
      case 3:
        return SettingsDoubleTextAndAccessoryTableViewCell.reuseIdentifier
      default:
        return SettingsTextAndAccessoryTableViewCell.reuseIdentifier
      }
      
    default:
      fatalError("Overbound Sections")
    }
  }
  
  private func sectionHeader(for section: Int) -> String {
    switch section {
    case 0:
      return NSLocalizedString("basic-settings", comment: "Basic")
    case 1:
      return NSLocalizedString("additional-settings", comment: "Additional")
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
    
    cell.titleLabel.text = NSLocalizedString("push-notifications-title", comment: "Push Notifications")
    cell.subtitleLabel.text = NSLocalizedString("push-notifications-subtitle", comment: "Receive push notifications of new promo codes")
    
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
  
  private func configureClearCacheCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsTextAndAccessoryTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = NSLocalizedString("clear-cache-title", comment: "Clear Cache")
    
    return cell
  }
  
  private func configureSharePromoCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsDoubleTextAndAccessoryTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = NSLocalizedString("share-promocode-title", comment: "Share Your Promo Code")
    cell.subtitleLabel.text = NSLocalizedString("share-promocode-subtitle", comment: "Found a new promo code?\nSend us and we will add it")
    
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
  
  private func configureFeedbackCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsTextAndAccessoryTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = NSLocalizedString("give-feedback-title", comment: "Give Feedback")
    
    return cell
  }
  
  private func configureContactUsCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsDoubleTextAndAccessoryTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = NSLocalizedString("contact-us-title", comment: "To Contact Us")
    cell.subtitleLabel.text = "example@mail.com"
    cell.subtitleLabel.textColor = UIColor(named: "BlueTintColor")
    
    return cell
  }
}

  // MARK: - Actions
extension SettingsTableViewController {
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 0:
        return nil
      default:
        return indexPath
      }
      
    case 1:
      return indexPath
//      switch indexPath.row {
//      case 3:
//        return nil
//      default:
//        return indexPath
//      }
      
    default:
      return indexPath
    }
  }
  
  private func showScreen(for indexPath: IndexPath) {
    
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 1:
        showClearCacheAlert()
      case 2:
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
      case 3:
        showContactUsScreen()
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
  
  private func showContactUsScreen() {
    if MFMailComposeViewController.canSendMail() {
      let email = "example@mail.com"
      let composeVC = MFMailComposeViewController()
      composeVC.mailComposeDelegate = self
      composeVC.setToRecipients([email])
      composeVC.setSubject(NSLocalizedString("contact-us-title", comment: "For Commercial Use"))
      
      self.present(composeVC, animated: true)
    }
  }
}

  // MARK: - Email Delegate
extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    
    controller.dismiss(animated: true)
  }
}

  // MARK: - Alerts
extension SettingsTableViewController {
  
  // MARK: - Push Alert
  private func showPushDisabledAlert() {
    let alertController = UIAlertController(title: NSLocalizedString("notifications-alert-title", comment: "No Access to Notifications"),
                                            message: NSLocalizedString("notifications-alert-subtitle", comment: "Please, allow notifications for GetCoupon app in settings."),
                                            preferredStyle: .alert)
    let action = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
    alertController.addAction(action)
    
    present(alertController, animated: true, completion: nil)
  }
  
  // MARK: - Cache Alert
  private func showClearCacheAlert() {
    let title = NSLocalizedString("deleting-images-alert-title", comment: "Deleting Cached Images")
    let message = NSLocalizedString("deleting-images-alert-subtitle", comment: "All cached images will be deleted.")
    let cancelButtonTile = NSLocalizedString("cancel", comment: "Cancel")
    let destructiveButtonTitle = NSLocalizedString("deleting-images-alert-done", comment: "Clear Cache")
    
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
    let alertController = UIAlertController(title: NSLocalizedString("review-alert-title", comment: "Rate Our App"),
                                            message: NSLocalizedString("review-alert-subtitle", comment: "Please leave a review about the application."),
                                            preferredStyle: .alert)
    let action = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
    alertController.addAction(action)
    
    present(alertController, animated: true, completion: nil)
  }
}
