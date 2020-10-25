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
  
  private let serversDatasource = "https://usrnm242.github.io/getcoupon/conf.json"
  private let basicAuthorization = "Basic YWxpdmUtZ2V0Y291cG9uLXVzZXI6OW1sNzBEbzdqWHRtMDVIS0s="
    
  private let disposeBag = DisposeBag()
  private let defaultScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  private let updatesScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
  
  let serverPack = BehaviorRelay<ServersPack?>(value: nil)
  
  let connectionStatusSatisfied = Observable<Void>.create { observer in
    debugPrint("Waiting for network...")
    let queue = DispatchQueue(label: "NetwokMonitor", qos: .default)
    let monitor = NWPathMonitor()
    
    monitor.pathUpdateHandler = { currentPath in
      if currentPath.status == .satisfied {
        observer.onNext(())
        observer.onCompleted()
      }
    }
    
    monitor.start(queue: queue)
    
    return Disposables.create {
      monitor.cancel()
    }
  }
}

  // MARK: - Download Images
extension NetworkController {
  
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
  
  func setupServerPack() -> Observable<Void> {
    let subject = PublishSubject<Void>()
    
    guard let url = URL(string: serversDatasource) else {
      subject.onCompleted()
      return subject.asObservable()
    }
    
    URLSession.shared.rx.data(request: URLRequest(url: url))
      .observeOn(updatesScheduler)
      .map { (data: Data) -> ServersPack in
        let decoder = JSONDecoder()
        return try decoder.decode(ServersPack.self, from: data)
      }
      .subscribe(onNext: { [weak self] servers in
        self?.serverPack.accept(servers)
        
        subject.onNext(())
      }, onError: { error in
          subject.onError(error)
      }, onCompleted: {
        subject.onCompleted()
      })
      .disposed(by: disposeBag)
    
    return subject.asObservable()
  }
  
  func downloadCollections() -> Observable<[NetworkShopCategoryData]> {
    let subject = PublishSubject<[NetworkShopCategoryData]>()
    
    guard let server = serverPack.value?.defaultServer,
      let url = URL(string: server.baseServerLink + server.database) else {
      subject.onCompleted()
      return subject.asObservable()
    }
    
    let maxAttemps = 3
    
    var request = URLRequest(url: url)
    request.addValue(basicAuthorization, forHTTPHeaderField: "Authorization")
    
    URLSession.shared.rx.data(request: request)
      .observeOn(self.updatesScheduler)
      .retryWhen { e in
        return e.enumerated().flatMap { [weak self] attempt, error -> Observable<Int> in
          guard let self = self else {
            return Observable.just(1)
          }
          if attempt >= maxAttemps - 1 {
            return Observable.error(error)
          } else {
            debugPrint("Retry after \(attempt + 2 + attempt * maxAttemps)")
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
      .bind(to: subject)
      .disposed(by: self.disposeBag)
    
    return subject.asObservable()
  }
}

  // MARK: - Download Promotional Offer
extension NetworkController {
  
  func downloadAdvOffer() -> Observable<[NetworkAdvertisingCategoryData]> {
    let subject = PublishSubject<[NetworkAdvertisingCategoryData]>()
    guard let server = serverPack.value?.defaultServer,
      let url = URL(string: server.baseServerLink + server.adv) else {
        subject.onCompleted()
        return subject.asObservable()
    }
    
    let maxAttemps = 3
    
    var request = URLRequest(url: url)
    request.addValue(basicAuthorization, forHTTPHeaderField: "Authorization")
    
    URLSession.shared.rx.data(request: request)
      .observeOn(self.updatesScheduler)
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
        return try decoder.decode([NetworkAdvertisingCategoryData].self, from: data)
      }
      .bind(to: subject)
      .disposed(by: self.disposeBag)
    
    return subject.asObservable()
  }
}

  // MARK: - Sending Data to Server
extension NetworkController {
  
  private func sendData(_ data: Data, to url: URL) {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(basicAuthorization, forHTTPHeaderField: "Authorization")
    
    URLSession.shared.uploadTask(with: request, from: data).resume()
  }
}

  // MARK: - Send Feedbacks
extension NetworkController {
  
  private func sendFeedback(_ params: [String : String], url: URL) {
    do {
      let data = try JSONSerialization.data(withJSONObject: params)
      
      sendData(data, to: url)
      
    } catch {
      debugPrint(error)
    }
  }
  
  func sendGeneralFeedback(_ feedback: String) {
    guard let server = serverPack.value?.defaultServer,
      let url = URL(string: server.baseServerLink + server.feedbackGeneralLink) else {
      return
    }
    
    let params = ["feedback" : feedback]
    
    self.sendFeedback(params, url: url)
  }
  
  func sendCoupon(_ coupon: String) {
    guard let server = serverPack.value?.defaultServer,
      let url = URL(string: server.baseServerLink + server.feedbackCouponLink) else {
      return
    }
    
    let params = ["promocode" : coupon]
    
    self.sendFeedback(params, url: url)
  }
}

  // MARK: - Send Remote Notifications Configuration
extension NetworkController {
  
  func sendConfiguration(_ config: Data) {
    guard let server = serverPack.value?.defaultServer,
      let url = URL(string: server.baseServerLink + server.pushConfigurationLink) else {
      return
    }
    
    debugPrint("SEND: " + (String(data: config, encoding: .utf8) ?? ""))
    
    sendData(config, to: url)
  }
}

  // MARK: - Download Terms of Service
extension NetworkController {
  
  var license: Observable<String?> {
    guard let licenseLink = self.serverPack.value?.license,
      let url = URL(string: licenseLink) else {
        return Observable.empty()
    }
    
    return Observable.create { [weak self] observer in
      guard let self = self else {
        observer.onCompleted()
        return Disposables.create()
      }
      
      URLSession.shared.rx.data(request: URLRequest(url: url))
        .observeOn(self.defaultScheduler)
        .map { data in
          return String(data: data, encoding: .utf8)
        }
        .bind(to: observer)
        .disposed(by: self.disposeBag)
      
      return Disposables.create()
    }
  }
}
