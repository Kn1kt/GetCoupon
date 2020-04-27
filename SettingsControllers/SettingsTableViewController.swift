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
  }
  
  private func bindViewModel() {
      
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
      return 5
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
      case 1:
        return configureEmailNotificationsCell(cell)
      case 2:
        return configureForceUpdatingCell(cell)
      case 3:
        return configureClearCacheCell(cell)
      case 4:
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
      case 0, 1, 2:
        return SettingsDoubleTextAndSwitchTableViewCell.reuseIdentifier
      case 4:
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
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
  
  // MARK: - Configuring Cells
extension SettingsTableViewController {
  
  private func configurePushNotificationsCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsDoubleTextAndSwitchTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = "Push Notifications"
    cell.subtitleLabel.text = "Receive push notifications of new promo codes"
    
    viewModel.pushNotificationsDisabled
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] isOn in
        cell.switcher.setOn(isOn, animated: true)
        let alertController = UIAlertController(title: "No Access to Notifications",
                                                message: "Please, allow notifications for GetCoupon app in settings.",
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self?.present(alertController, animated: true, completion: nil)
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
  
    private func configureEmailNotificationsCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
      guard let cell = tableViewCell as? SettingsDoubleTextAndSwitchTableViewCell else {
        return tableViewCell
      }
      
      cell.titleLabel.text = "Receive Email Notifications"
      cell.subtitleLabel.text = "Every week you will receive an email with new promotional codes"
      
      cell.switcher.isOn = false
  //    cell.switcher.rx.isOn
  //      .skip(1)
  //      .subscribeOn(eventScheduler)
  //      .observeOn(eventScheduler)
  //      .bind(to: viewModel.forceCatalogUpdating)
  //      .disposed(by: cell.disposeBag)
      
      return cell
    }
  
  private func configureForceUpdatingCell(_ tableViewCell: UITableViewCell) -> UITableViewCell {
    guard let cell = tableViewCell as? SettingsDoubleTextAndSwitchTableViewCell else {
      return tableViewCell
    }
    
    cell.titleLabel.text = "Force Catalog Updating"
    cell.subtitleLabel.text = "Update promo codes automatically every time you open the application"
    
    cell.switcher.isOn = viewModel.forceCatalogUpdating.value
    cell.switcher.rx.isOn
      .skip(1)
//      .map { cell.switcher.isOn }
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
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if indexPath.section == 0, indexPath.row == 3 {
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
      tableView.deselectRow(at: indexPath, animated: true)
    }
    
    if indexPath.section == 1, indexPath.row == 1 {
      
      let storyboard = UIStoryboard(name: "SettingsTermsOfService", bundle: nil)
      let vc = storyboard.instantiateViewController(identifier: "SettingsTermsOfService")
      show(vc, sender: self)
    }
    
    if indexPath.section == 0, indexPath.row == 4 {
      viewModel.showFeedbackVC.accept((self, FeedbackViewModel.FeedbackType.coupon))
      tableView.deselectRow(at: indexPath, animated: true)
    }
    
    if indexPath.section == 1, indexPath.row == 2 {
      viewModel.showFeedbackVC.accept((self, FeedbackViewModel.FeedbackType.general))
      tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    tableView.deselectRow(at: indexPath, animated: true)
  }
}
