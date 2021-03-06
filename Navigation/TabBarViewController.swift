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

protocol ScrollToTopGestureProtocol {
  var scrollToTop: PublishRelay<Void> { get }
}

class TabBarViewController: UITabBarController {
  
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    delegate = self
    
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

extension TabBarViewController: UITabBarControllerDelegate {
  
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    if let selectedVC = selectedViewController,
      selectedVC == viewController {
      
      if let nc = viewController as? UINavigationController,
        let topVC = nc.topViewController as? ScrollToTopGestureProtocol {
        topVC.scrollToTop.accept(())
      }
    }
    
    return true
  }
}
