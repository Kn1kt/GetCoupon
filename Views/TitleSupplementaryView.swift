//
//  TitleSuplementoryView.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class TitleSupplementaryView: UICollectionReusableView {
  
  let label = UILabel()
  let showMoreButton = ShowMoreUIButton()
  var disposeBag = DisposeBag()
  
  static let reuseIdentifier = "title-supplementary-reuse-identifier"
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("Not implemented")
  }
}

extension TitleSupplementaryView {
  
  func setupLayouts() {
    showMoreButton.translatesAutoresizingMaskIntoConstraints = false
    label.translatesAutoresizingMaskIntoConstraints = false
    label.adjustsFontForContentSizeCategory = true
//    label.font = UIFont.preferredFont(forTextStyle: .title1)
    label.font = UIFont.boldSystemFont(ofSize: 27)
    
    addSubview(label)
    addSubview(showMoreButton)
    
    let inset = CGFloat(10)
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
      label.trailingAnchor.constraint(equalTo: showMoreButton.leadingAnchor, constant: -inset),
      label.topAnchor.constraint(equalTo: topAnchor, constant: inset),
      label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
      
      showMoreButton.trailingAnchor.constraint(equalTo: trailingAnchor),
      showMoreButton.topAnchor.constraint(equalTo: topAnchor, constant: inset),
      showMoreButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
      showMoreButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2)
    ])
  }
}

extension TitleSupplementaryView {
  override func prepareForReuse() {
    showMoreButton.isEnabled = false
    showMoreButton.isHidden = true
    
    disposeBag = DisposeBag()
  }
}
