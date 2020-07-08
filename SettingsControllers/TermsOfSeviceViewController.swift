//
//  TermsOfSeviceViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 15.04.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class TermsOfSeviceViewController: UIViewController {
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  
  override func viewDidLoad() {
    super.viewDidLoad()
     
    textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 40, right: 10)
    
    NetworkController.shared.license
      .subscribeOn(defaultScheduler)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] text in
        guard let self = self,
          let license = text else { return }
        
        self.activityIndicator.stopAnimating()
        self.textView.text = license
      })
      .disposed(by: disposeBag)
  }
}
