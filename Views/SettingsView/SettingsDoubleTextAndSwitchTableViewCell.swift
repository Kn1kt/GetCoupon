//
//  SettingsDoubleTextAndSwitchTableViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 15.04.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class SettingsDoubleTextAndSwitchTableViewCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var switcher: UISwitch!
  static let reuseIdentifier = "SettingsDoubleTextAndSwitchTableViewCellReuseIdentifier"

  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
