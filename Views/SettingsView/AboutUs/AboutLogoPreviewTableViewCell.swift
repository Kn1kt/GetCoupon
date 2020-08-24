//
//  AboutLogoPreviewTableViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 22.08.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class AboutLogoPreviewTableViewCell: UITableViewCell {
  
  static let reuseIdentifier = "AboutLogoPreviewTableViewCellReuseIdentifier"
  private let version = NSLocalizedString("version", comment: "Version") + " 1.2.0"
  
  // MARK: - Views
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var largeTitleLabel: UILabel!
  @IBOutlet weak var largeSubtitleLabel: UILabel!
  
  // MARK: - View Constraints
  @IBOutlet weak var hStackHeight: NSLayoutConstraint!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    largeSubtitleLabel.text = version
    
    logoImageView.clipsToBounds = true
    logoImageView.layer.cornerRadius = 30
    logoImageView.layer.borderWidth = 1
    logoImageView.layer.borderColor = UIColor.systemGray5.cgColor
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    logoImageView.layer.borderColor = UIColor.systemGray5.cgColor
  }
}
