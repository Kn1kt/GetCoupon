//
//  TabBarViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 11.07.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TabBarViewController: UITabBarController {
  
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ModelController.shared.defaultTabBarItem
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] index in
        guard let self = self else { return }
        
        if index != self.selectedIndex {
          
          self.selectedIndex = index
          print("SELECT")
        }
      })
    .disposed(by: disposeBag)
  }
}
