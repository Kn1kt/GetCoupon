//
//  AboutLogoPreviewTableViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 22.08.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AboutLogoPreviewTableViewCell: UITableViewCell {
  
  static let reuseIdentifier = "AboutLogoPreviewTableViewCellReuseIdentifier"
  private let version = NSLocalizedString("version", comment: "Version") + " 1.2.0"
  
  // MARK: - Views
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var textView: UIView!
  @IBOutlet weak var textSubtitleLabel: UILabel!
  @IBOutlet weak var largeTitleLabel: UILabel!
  @IBOutlet weak var largeSubtitleLabel: UILabel!
  
  // MARK: - View Constraints
  @IBOutlet weak var hStackHeight: NSLayoutConstraint!
  
  var disposeBag = DisposeBag()
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    textSubtitleLabel.text = version
    largeSubtitleLabel.text = version
    
    logoImageView.clipsToBounds = true
    logoImageView.layer.cornerRadius = 30
    logoImageView.layer.borderWidth = 1
    logoImageView.layer.borderColor = UIColor.systemGray5.cgColor
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    disposeBag = DisposeBag()
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    logoImageView.layer.borderColor = UIColor.systemGray5.cgColor
  }
}

  // MARK: - Animations
extension AboutLogoPreviewTableViewCell {
  
  func shouldShowScaleInLogo(_ scale: Bool, animated: Bool = true) {
    if animated {
      UIView.animate(withDuration: 0.5, animations: { [weak self] in
        self?.updateScale(scale)
      })
      
    } else {
      updateScale(scale)
    }
  }
  
  private func updateScale(_ scale: Bool) {
    self.textView.isHidden = scale
    self.largeTitleLabel.isHidden = !scale
    self.largeSubtitleLabel.isHidden = !scale

    if scale {
      self.textView.alpha = 0
      self.largeTitleLabel.alpha = 1
      self.largeSubtitleLabel.alpha = 1
      
      self.scaleIn()
      
    } else {
      self.textView.alpha = 1
      self.largeTitleLabel.alpha = 0
      self.largeSubtitleLabel.alpha = 0
      
      self.scaleOut()
    }

    self.contentView.layoutIfNeeded()
  }
  
  private func scaleOut() {
    hStackHeight.constant = 120
    logoImageView.layer.cornerRadius = 30
  }
  
  private func scaleIn() {
    hStackHeight.constant = 240
    logoImageView.layer.cornerRadius = 60
  }
}
