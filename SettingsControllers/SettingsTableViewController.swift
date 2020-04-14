//
//  SettingsTableViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 04.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.tintColor = UIColor(named: "BlueTintColor")
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    switch section {
    case 0:
      return 5
    case 1:
      return 2
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
    
    if let c = cell as? SettingsTextAndAccessoryTableViewCell {
      c.titleLabel.text = cellTitle(for: indexPath)
    } else if let c = cell as? SettingsTextAndSwitchTableViewCell {
      c.titleLabel.text = cellTitle(for: indexPath)
    } else if let c = cell as? SettingsDoubleTextAndAccessoryTableViewCell {
      c.titleLabel.text = cellTitle(for: indexPath)
      c.subtitleLabel.text = cellSubtitle(for: indexPath)
    } else if let c = cell as? SettingsDoubleTextAndSwitchTableViewCell {
      c.titleLabel.text = cellTitle(for: indexPath)
      c.subtitleLabel.text = cellSubtitle(for: indexPath)
    }
    
    return cell
  }
  
  private func cellReuseIdentifier(for indexPath: IndexPath) -> String {
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 0:
        return SettingsTextAndSwitchTableViewCell.reuseIdentifier
      case 1:
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
  
  private func cellTitle(for indexPath: IndexPath) -> String {
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 0:
        return "Push Notifications"
      case 1:
        return "Receive Email Notifications"
      case 2:
        return "Clear Cache"
      case 3:
        return "Force Catalog Updating"
      case 4:
        return "Share Your Promo Code"
      default:
        fatalError("Overbound Rows")
      }
      
    case 1:
      switch indexPath.row {
      case 0:
        return "Rate Us"
      case 1:
        return "Terms of Service"
      default:
        fatalError("Overbound Rows")
      }
      
    default:
      fatalError("Overbound Sections")
    }
  }
  
  private func cellSubtitle(for indexPath: IndexPath) -> String{
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 1:
        return "Every week you will receive an email with new promotional codes"
      case 4:
        return "Found a new promo code?\nSend us and we will add it"
      default:
        fatalError("Incorrect Row")
      }
      
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

// MARK: - Clear Buttons
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
    
    if indexPath.section == 0, indexPath.row == 2 {
      ModelController.shared.removeCollectionsFromStorage()
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
