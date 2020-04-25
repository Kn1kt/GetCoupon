//
//  SettingsTextAndSwitchTableViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 14.04.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class SettingsTextAndSwitchTableViewCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var switcher: UISwitch!
  static let reuseIdentifier = "SettingsTextAndSwitchTableViewCellReuseIdentifier"
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
