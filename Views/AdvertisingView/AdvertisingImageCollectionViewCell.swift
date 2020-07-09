//
//  AdverstingImageCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 28.05.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class AdvertisingImageCollectionViewCell: UICollectionViewCell {

  static let reuseIdentifier = "adversting-image-cell-reuse-identifier"
  
  var disposeBag = DisposeBag()
  
  let imageView = UIImageView()
//  let adMark = AdvertisingMarkView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

  // MARK: - Layouts
extension AdvertisingImageCollectionViewCell {
  
  func setupLayouts() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
//    adMark.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(imageView)
//    contentView.addSubview(adMark)
    
    selectedBackgroundView = UIView()
    selectedBackgroundView?.backgroundColor = UIColor.systemGray.withAlphaComponent(0.4)
    layer.cornerRadius = 10
    clipsToBounds = true
    
    imageView.layer.cornerRadius = 7
    imageView.backgroundColor = .systemGray3
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    
//    let spacing = CGFloat(10)
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      
//      adMark.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
//      adMark.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing)
    ])
    
  }
}

  //MARK: - CellWithImageProtocol
extension AdvertisingImageCollectionViewCell: CellWithImage {
  
  override func prepareForReuse() {
    disposeBag = DisposeBag()
    imageView.image = nil
    imageView.backgroundColor = .systemGray3
  }
}
