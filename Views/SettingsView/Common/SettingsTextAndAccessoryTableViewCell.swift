//
//  SettingsTextAndAccessoryTableViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 14.04.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class SettingsTextAndAccessoryTableViewCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  static let reuseIdentifier = "SettingsTextAndAccessoryTableViewCellReuseIdentifier"
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
