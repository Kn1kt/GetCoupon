//
//  Router.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 08.03.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Navigator {
  
  // MARK: - segue list
  enum Segue {
    case homeDetailScreen(section: ShopCategoryData)
    case shopScreen
  }
  
  // MARK: - invoke a single segue
  func showHomeDetailVC(sender: UIViewController,
                        model: HomeDataController,
                        section: Observable<ShopCategoryData>) {
    let vm = HomeDetailViewModel(navigator: self,
                                 model: model,
                                 section: section)
    let vc = HomeDetailViewController.createWith(viewModel: vm)
    
    show(target: vc, sender: sender)
  }
  
  func showShopVC(sender: UIViewController,
                  section: ShopCategoryData,
                  shop: ShopData) {
    let vm = ShopViewModel(navigator: self,
                           section: section,
                           shop: shop)
    let vc = ShopViewController.createWith(viewModel: vm)
    
    showShop(target: vc, sender: sender)
  }
  
//  func show(segue: Segue, sender: UIViewController) {
//    switch segue {
//    case .homeDetailScreen(let section):
//      let vm = HomeDetailViewModel()
//      show(target: HomeDetailViewController.createWith(section: section,
//                                                       navigator: self,
//                                                       viewModel: vm),
//           sender: sender)
//    case .shopScreen:
//      print("JUST SOME STUB")
//
////    default:
////      fatalError("Incorrect Segue")
//    }
//  }
  
  // Need test this implementation
  private func show(target: UIViewController, sender: UIViewController) {
    if let nav = sender.navigationController {
      //add controller to navigation stack
      nav.show(target, sender: sender)
    } else {
      //present modally
      sender.present(target, animated: true, completion: nil)
    }
    
  }
  
  private func showShop(target: UIViewController, sender: UIViewController) {
    let navController = UINavigationController(rootViewController: target)
    sender.present(navController, animated: true)
  }
}

