//
//  NextButton.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 05.07.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import RxSwift

class NextButton: UIButton {
  let disposeBag = DisposeBag()
  
  let isHiglightedSubject = PublishSubject<Bool>()
  
  override var isHighlighted: Bool {
    willSet {
      isHiglightedSubject.onNext(newValue)
    }
  }
}
