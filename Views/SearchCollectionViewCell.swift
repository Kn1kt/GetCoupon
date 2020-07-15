//
//  SearchCollectionViewCell.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 02.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class SearchCollectionViewCell: UICollectionViewCell {
  
  var disposeBag = DisposeBag()
  
  static let reuseIdentidier = "search-cell-reuse-identifier"
  
  let searchBar = UISearchBar()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

  // MARK: - Layouts
extension SearchCollectionViewCell {
  
  func setupLayouts() {
    
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchBar.searchBarStyle = .minimal
    searchBar.placeholder = NSLocalizedString("search", comment: "Search")
    
    contentView.addSubview(searchBar)
    
    contentView.clipsToBounds = true
    
    NSLayoutConstraint.activate([
      searchBar.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      searchBar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    ])
  }
}

extension SearchCollectionViewCell {
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
}
