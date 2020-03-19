import UIKit
import RxSwift
import RxCocoa


  let relay = BehaviorRelay<String>(value: "Initial value")
  let disposeBag = DisposeBag()
  
  let shopDidEdit = relay
    .scan(true) { prev, _ in
      return !prev
    }
    .subscribe(onNext: { s in
      print(s)
    })

