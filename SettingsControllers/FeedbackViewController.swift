//
//  FeedbackViewController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 21.04.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FeedbackViewController: UIViewController {
  
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  @IBOutlet weak var sendButton: UIBarButtonItem!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var textViewBottom: NSLayoutConstraint!
  
  private let disposeBag = DisposeBag()
  private let defaultSheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let eventScheduler = ConcurrentDispatchQueueScheduler(qos: .userInteractive)
  
  private var viewModel: FeedbackViewModel!
  
  static func createWith(viewModel: FeedbackViewModel) -> UIViewController {
    let storyboard = UIStoryboard(name: "SettingsFeedbackScreen", bundle: nil)
    guard let nc = storyboard
      .instantiateViewController(identifier: "SettingsFeedbackNavigationController") as? UINavigationController,
          let vc = nc.topViewController as? FeedbackViewController else {
      fatalError("NoFeedbackVC")
    }
    
    vc.viewModel = viewModel
    return nc
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    
    textView.becomeFirstResponder()
    
    updateLabels()
    
    bindViewModel()
    bindUI()
  }
  
  private func bindViewModel() {
    
  }
  
  private func bindUI() {
    textView.rx.text
      .map { (string: String?) -> Bool in
        if let text = string?.trimmingCharacters(in: .whitespaces),
          !text.isEmpty {
          return true
        }
        
        return false
      }
      .distinctUntilChanged()
      .subscribeOn(defaultSheduler)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] isEnabled in
        self.sendButton.isEnabled = isEnabled
      })
      .disposed(by: disposeBag)
    
    
    cancelButton.rx.tap
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] in
        self.dismiss(animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    sendButton.rx.tap
      .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribeOn(MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] in
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        
        if let text = self.textView.text?.trimmingCharacters(in: .whitespaces) {
          self.viewModel.feedbackText.accept(text)
        }
        
        self.dismiss(animated: true, completion: nil)
        
        notificationFeedbackGenerator.notificationOccurred(.success)
      })
      .disposed(by: disposeBag)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
  }
  
  private func updateLabels() {
    navigationItem.title = viewModel.navBarTitleText
    titleLabel.text = viewModel.titleText
    subtitleLabel.text = viewModel.subtitleText
  }
  
  @objc func keyboardDidShow(notification: NSNotification) {
    let info = notification.userInfo!
    let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

    UIView.animate(withDuration: 0.1, animations: {
      self.textViewBottom.constant = keyboardFrame.size.height
    })
  }
  
  @objc func keyboardDidHide(notification: NSNotification) {
    UIView.animate(withDuration: 0.1, animations: {
      self.textViewBottom.constant = 0
    })
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
