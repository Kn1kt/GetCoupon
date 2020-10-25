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
  
  // MARK: - Segue List
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
                  shop: ShopData,
                  favoritesButton: Bool = true) {
    let vm = ShopViewModel(navigator: self,
                           section: section,
                           shop: shop,
                           favoriteButtonEnabled: favoritesButton)
    let vc = ShopViewController.createWith(viewModel: vm)
    
    showShop(target: vc, sender: sender)
  }
  
  func showFedbackVC(sender: UIViewController,
                     feedbackType: FeedbackViewModel.FeedbackType) {
    let vm = FeedbackViewModel(feedbackType: feedbackType)
    let nc = FeedbackViewController.createWith(viewModel: vm)
    
    sender.present(nc, animated: true)
  }
  
  // Need test this implementation
  private func show(target: UIViewController, sender: UIViewController) {
    if let nav = sender.navigationController {
      nav.show(target, sender: sender)
    } else {
      sender.present(target, animated: true, completion: nil)
    }
    
  }
  
  private func showShop(target: UIViewController, sender: UIViewController) {
    let navController = UINavigationController(rootViewController: target)
    sender.present(navController, animated: true)
  }
  
  private func showFeedback(target: FeedbackViewController, sender: UIViewController) {
    let navController = target.navigationController!
    sender.present(navController, animated: true)
  }
}

