//
//  NetworkController.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 12.01.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import UIKit
import Network
import RxSwift
import RxCocoa

class NetworkController {
  
  enum NetworkError: Error {
    case URLNotCorrect
    case loadingError
  }
  
  static let shared = NetworkController()
  
//  private let serverLink = "https://www.dropbox.com/s/qge216pbfilhy08/collections.json?dl=1"
  private let serverLink = "http://closeyoureyes.jelastic.regruhosting.ru/ios-collections.json"
  private let advLink = ""
  
  /// Image processing queue
  private let queue = OperationQueue()
  
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let updatesScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
  
  /// Download Image
  func downloadImage(for urlString: String) -> Observable<UIImage> {
    guard let link = urlString
      .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
      let url = URL(string: link) else {
        return Observable.error(NetworkError.URLNotCorrect)
    }
    
    return URLSession.shared.rx.data(request: URLRequest(url: url))
      .retryWhen { e in
        return e.enumerated().flatMap { [weak self] attempt, error -> Observable<Int> in
          guard let self = self else {
            return Observable.just(1)
          }
          if attempt >= 1 {
            return Observable.error(error)
          } else {
            print("Retry after \(attempt + 2 + attempt * 2)")
            return Observable<Int>.timer(RxTimeInterval.seconds(attempt + 2 + attempt * 2), scheduler: self.updatesScheduler)
              .take(1)
          }
        }
      }
      .timeout(RxTimeInterval.seconds(10), scheduler: updatesScheduler)
      .map { data in
        guard let image = UIImage(data: data) else {
          throw NetworkError.loadingError
        }
        
        return image
      }
  }
}

  // MARK: - Download database
extension NetworkController {
  
  func downloadCollections() -> Observable<[NetworkShopCategoryData]> {
    let subject = PublishSubject<[NetworkShopCategoryData]>()
    
//    let queue = DispatchQueue(label: "monitor")
//    let monitor = NWPathMonitor()
//    monitor.start(queue: queue)
//    monitor.pathUpdateHandler = { [unowned self] currentPath in
      guard //currentPath.status == .satisfied,
        let url = URL(string: self.serverLink) else {
          subject.onCompleted()
          return subject.asObservable()
      }
      
//      monitor.cancel()
      
      let maxAttemps = 3
      
      URLSession.shared.rx.data(request: URLRequest(url: url))
        .retryWhen { e in
          return e.enumerated().flatMap { [weak self] attempt, error -> Observable<Int> in
            guard let self = self else {
              return Observable.just(1)
            }
            if attempt >= maxAttemps - 1 {
              return Observable.error(error)
            } else {
              print("Retry after \(attempt + 2 + attempt * maxAttemps)")
              return Observable<Int>.timer(RxTimeInterval.seconds(attempt + 2 + attempt * maxAttemps), scheduler: self.updatesScheduler)
                .take(1)
            }
          }
        }
        .timeout(RxTimeInterval.seconds(20), scheduler: updatesScheduler)
        .map { data in
          let decoder = JSONDecoder()
          return try decoder.decode([NetworkShopCategoryData].self, from: data)
        }
        .subscribeOn(self.updatesScheduler)
        .observeOn(self.updatesScheduler)
        .bind(to: subject)
        .disposed(by: self.disposeBag)
//    }
    
    return subject.asObservable()
  }
}

  // MARK: - Download Promotional Offer
extension NetworkController {
  
//  func downloadAdvOffer() -> Observable<[Any]> {
//    
//  }
}
