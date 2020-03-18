import UIKit
import RxSwift
import RxCocoa


  let relay = BehaviorRelay<String>(value: "Initial value")
  let disposeBag = DisposeBag()
  
  relay.accept("New initial value")
  
//  let tst = relay.asObservable().share(replay: 1)
  let tst = relay.asDriver()
  
  tst.drive(onNext: { print("from 1 asObservable: " + $0) })
  
  tst.drive(onNext: { print("from 2 asObservable: " + $0) })
  
//  relay.accept("New initial value 2")
//  relay
//    .subscribe {
//      print(label: "1)", event: $0)
//  }
//  .disposed(by: disposeBag)
//
//  relay.accept("1")
//
//  relay
//    .subscribe {
//      print(label: "2)", event: $0)
//
//  }
//  .disposed(by: disposeBag)
//
//  relay.accept("2")
//
//  print(relay.value)

