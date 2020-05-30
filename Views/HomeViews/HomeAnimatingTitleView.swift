//
//  HomeAnimatingTitleView.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 30.05.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit

class HomeAnimatingTitleView: UIView {
  
  let defaultTitle = UILabel()
  let downloadingTitle = UILabel()
  let downloadedTitle = UILabel()
  let errorTitle = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("not implemented")
  }
}

  // MARK: - Layouts
extension HomeAnimatingTitleView {
  
  func setupLayouts() {
    defaultTitle.translatesAutoresizingMaskIntoConstraints = false
    downloadingTitle.translatesAutoresizingMaskIntoConstraints = false
    downloadedTitle.translatesAutoresizingMaskIntoConstraints = false
    errorTitle.translatesAutoresizingMaskIntoConstraints = false
    
    self.addSubview(defaultTitle)
    self.addSubview(downloadingTitle)
    self.addSubview(downloadedTitle)
    self.addSubview(errorTitle)
    
    defaultTitle.alpha = 0
    downloadingTitle.alpha = 0
    downloadedTitle.alpha = 0
    errorTitle.alpha = 0
    
    defaultTitle.font = UIFont.boldSystemFont(ofSize: 17)
    defaultTitle.adjustsFontForContentSizeCategory = true
    defaultTitle.textAlignment = .center
    defaultTitle.textColor = .label
    
    downloadingTitle.font = UIFont.boldSystemFont(ofSize: 17)
    downloadingTitle.adjustsFontForContentSizeCategory = true
    downloadingTitle.textAlignment = .center
    downloadingTitle.textColor = .label
    
    downloadedTitle.font = UIFont.boldSystemFont(ofSize: 17)
    downloadedTitle.adjustsFontForContentSizeCategory = true
    downloadedTitle.textAlignment = .center
    downloadedTitle.textColor = .label
    
    errorTitle.font = UIFont.boldSystemFont(ofSize: 17)
    errorTitle.adjustsFontForContentSizeCategory = true
    errorTitle.textAlignment = .center
    errorTitle.textColor = .label
    
    NSLayoutConstraint.activate([
      defaultTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      defaultTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      defaultTitle.topAnchor.constraint(equalTo: self.topAnchor),
      defaultTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      
      downloadingTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      downloadingTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      downloadingTitle.topAnchor.constraint(equalTo: self.topAnchor),
      downloadingTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      
      downloadedTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      downloadedTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      downloadedTitle.topAnchor.constraint(equalTo: self.topAnchor),
      downloadedTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      
      errorTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      errorTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      errorTitle.topAnchor.constraint(equalTo: self.topAnchor),
      errorTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
  }
}

  // MARK: - Animations
extension HomeAnimatingTitleView {
  
  func setDefaultTitle(to text: String) {
    defaultTitle.text = text
    defaultTitle.alpha = 0
    defaultTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    UIView.animate(withDuration: 0.3, animations: { [weak self] in
      self?.defaultTitle.transform = .identity
      self?.defaultTitle.alpha = 1
      
      self?.downloadingTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      self?.downloadingTitle.alpha = 0
      self?.downloadedTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      self?.downloadedTitle.alpha = 0
      self?.errorTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      self?.errorTitle.alpha = 0
    })
  }
  
  func setDownloadingTitle(to text: String) {
    downloadingTitle.text = text
    downloadingTitle.alpha = 0
    downloadingTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    UIView.animate(withDuration: 0.3, animations: { [weak self] in
      self?.downloadingTitle.transform = .identity
      self?.downloadingTitle.alpha = 1
      
      self?.defaultTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      self?.defaultTitle.alpha = 0
      self?.downloadedTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      self?.downloadedTitle.alpha = 0
      self?.errorTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      self?.errorTitle.alpha = 0
    })
  }
  
  func setDownloadedTitle(to text: String) {
    downloadedTitle.text = text
    downloadedTitle.alpha = 0
    downloadedTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    UIView.animate(withDuration: 0.3, animations: { [weak self] in
      self?.downloadedTitle.transform = .identity
      self?.downloadedTitle.alpha = 1
      
      self?.defaultTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      self?.defaultTitle.alpha = 0
      self?.downloadingTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      self?.downloadingTitle.alpha = 0
      self?.errorTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      self?.errorTitle.alpha = 0
    })
  }
  
  func setErrorTitle(to text: String) {
    errorTitle.text = text
    errorTitle.alpha = 0
    errorTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    UIView.animate(withDuration: 0.3, animations: { [weak self] in
      self?.errorTitle.transform = .identity
      self?.errorTitle.alpha = 1
      
      self?.defaultTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      self?.defaultTitle.alpha = 0
      self?.downloadingTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      self?.downloadingTitle.alpha = 0
      self?.downloadedTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      self?.downloadedTitle.alpha = 0
    })
  }
}
