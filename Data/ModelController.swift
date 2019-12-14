//
//  Model.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 25.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class ModelController {
    
    /// Main Collection
    static private var needSaveToStorage: Bool = false
    static fileprivate var _collections: [ShopCategoryData] = []
    static private let collectionsQueue = DispatchQueue(label: "collectionsQueue", attributes: .concurrent)
    static var collections: [ShopCategoryData] {
        get {
            collectionsQueue.sync {
                return _collections
            }
        }
        
        set {
            collectionsQueue.async(flags: .barrier) {
                self._collections = newValue
                NotificationCenter.default.post(name: .didUpdateCollections, object: nil)
                updateFavoritesCollections()
                homeDataController.updateCollections()
                needSaveToStorage = true
            }
            //NotificationCenter.default.post(name: .didUpdateCollections, object: nil)
            //updateFavoritesCollections()
        }
    }
    
    /// Home Collections
    static var homeDataController: HomeDataController = createHomeDataController()
    
//    static var homeDataController: HomeDataController {
//
//        if _homeDataController == nil {
//            _homeDataController = createHomeDataController()
//        }
//
//        return _homeDataController!
//    }
    
//    static private var _homeCollections: [ShopCategoryData]?
//
//    static var homeCollections: [ShopCategoryData] {
//        get {
//            if _homeCollections == nil {
//                updateHomeCollections()
//            }
//
//            return _homeCollections!
//        }
//    }
    
    /// Favorites Collection
    static private var _favoritesDataController: FavoritesDataController?
    
    static var favoritesDataController: FavoritesDataController {
        
        if _favoritesDataController == nil {
            _favoritesDataController = createFavoritesDataController()
        }
        
        return _favoritesDataController!
    }
    
    static private var _favoritesCollections: [ShopCategoryData] = []
    
    static private let favoritesCollectionsQueue = DispatchQueue(label: "favoritesCollectionsQueue", attributes: .concurrent)
    static private var favoritesCollections: [ShopCategoryData] {
        get {
            favoritesCollectionsQueue.sync {
                return _favoritesCollections
            }
        }
        
        set {
            favoritesCollectionsQueue.async(flags: .barrier) {
                self._favoritesCollections = newValue
            }
        }
    }
    
    /// Search Collection
    static private var _searchCollection: ShopCategoryData?
    
    static var searchCollection: ShopCategoryData {
        get {
            if _searchCollection == nil {
                _searchCollection = setupSearchData()
            }
            
            return _searchCollection!
        }
    }
    
    
}

    // MARK: - Data Management

extension ModelController {
    
    static func updateCollections() {
        
        // There gonna be some database query methods
        
        generateCollections()
    }
    
    static func loadCollectionsToStorage() {
        
        guard needSaveToStorage else {
            return
        }
        
        //DispatchQueue.global(qos: .background).async {
            
            let directoryURL = FileManager.default.urls(for: .cachesDirectory,
                in: .userDomainMask).first
            let fileURL = URL(fileURLWithPath: "collections", relativeTo: directoryURL).appendingPathExtension("json")
            do {
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(collections)
                try jsonData.write(to: fileURL, options: .noFileProtection)
            } catch {
                debugPrint(error)
            }
            
            debugPrint("loaded to storage")
        //}
    }
    
    static func loadCollectionsFromStorage() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let directoryURL = FileManager.default.urls(for: .cachesDirectory,
                in: .userDomainMask).first
            let fileURL = URL(fileURLWithPath: "collections", relativeTo: directoryURL).appendingPathExtension("json")
            do {
                
                let jsonDecoder = JSONDecoder()
                let jsonData = try Data(contentsOf: fileURL)
                let decodedCollections = try jsonDecoder.decode([ShopCategoryData].self, from: jsonData)
                collections = decodedCollections
            } catch {
                debugPrint(error)
                generateCollections()
            }
            
            debugPrint("loaded from storage")
        }
    }
    
    static func removeCollectionsFromStorage() {
        
        let directoryURL = FileManager.default.urls(for: .cachesDirectory,
            in: .userDomainMask).first
        let fileURL = URL(fileURLWithPath: "collections", relativeTo: directoryURL).appendingPathExtension("json")
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            debugPrint(error)
        }
        needSaveToStorage = false
        debugPrint("deleted from storage")
    }
    
    
    static func section(for index: Int) -> ShopCategoryData? {
        guard index >= 0, collections.count > index else { return nil }
        
        return collections[index]
    }
    
    /// FOR TESTS
    static func generateCollections() {
        
        let promocodes: [PromocodeData] = [
            PromocodeData(coupon: "COUPON30",
                          addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 3),
                          estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 7),
                          description: "Save your 30% when spent more than 5000",
                          isHot: false),
            PromocodeData(coupon: "COUPON20",
                          addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 2),
                          estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 6),
                          description: "Amazing discounts up to 20% on sale!",
                          isHot: false),
            PromocodeData(coupon: "COUPON10",
                          addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 1),
                          estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 5),
                          description: "Save your 10% when spent more than 1000",
                          isHot: false),
            PromocodeData(coupon: "COUPON40",
                          addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 3),
                          estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 4),
                          description: "The promotional code for an additional discount of 40%.",
                          isHot: false),
            PromocodeData(coupon: "COUPON50",
                          addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 3),
                          estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 3),
                          description: "The promotional code for an additional discount of 50%.",
                          isHot: false),
            PromocodeData(coupon: "COUPON60",
                          addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 1),
                          estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 2),
                          description: "Amazing discounts up to 60% on sale!",
                          isHot: false),
            PromocodeData(coupon: "COUPON70",
                          addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 1),
                          estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 1),
                          description: "Save your 70% when spent more than 15000",
                          isHot: false),
            PromocodeData(coupon: "COUPON80",
                          addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 1),
                          estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 1),
                          description: "Amazing discounts up to 80% on sale!",
                          isHot: false),
            PromocodeData(coupon: "COUPON90",
                          addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 1),
                          estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 1),
                          description: "Amazing discounts up to 90% on sale!",
                          isHot: false)
        ]

        let collections: [ShopCategoryData] = [
            ShopCategoryData(categoryName: "HOT 🔥",
                             shops: [ShopData(name: "Delivery Club",
                                              description: "Delivery of dairy, farm products, confectionery and ready meals (pizza, sushi, barbecue, etc.).", shortDescription: "Save your 35%",
                                              websiteLink: "https://www.delivery-club.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/6932972b45782c8793f0d694176216f19b27ec9d9c8a316c48667c70ebdd0977/5df4830a/6Kh14hfMGNlw2RDaYgQdU7PBA12Ln9pTZ84ft--FCW6h4PWYrt9w7vAeDeUDWCvkXyj4WeD57QcA1iv9UxaK7g==?uid=0&filename=wok-1024x537.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2048x2048",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/168b777669b1dfd84f66c4f96f401dfd3d3994104ff51ef22025510932f712f9/5df4832c/5NKXKtJBuwV511UQavdzFivsXo8NFom8AGkC1C0PX0Wb2ipYAqyQSUUAtd_bmp0jG7SHtCBh_2csu9lwZplILg==?uid=0&filename=IBrWLeJ3jT0.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              placeholderColor: #colorLiteral(red: 0.6835173368, green: 0.8750453591, blue: 0.1662097871, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Yandex Food",
                                              description: "Order food from restaurants - fast delivery in 45 minutes.",
                                              shortDescription: "Save your 15%",
                                              websiteLink: "https://eda.yandex",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/4788de2acf5aa92c449d92a1e54bea35e0371616d1730f77af5dbfccb6e02e2c/5df48347/q8yr6qHzMTjCYOTf08pT7ewtrT4AL-jSNHHQETgZrDG3JAzmsaFqTjCD0zCsqBfnHoshsyAcz4GaYmjo19RIJQ==?uid=0&filename=scale_1200.webp&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/41697fe65b0204dfbccada2060e04f4f4ce37e3d412d033bbab8bfda9cfe9336/5df48354/hAvNqC_cUti8eVB1fsg8GqAcc9H6Mv9IEWADxHwPSaSWgEfWbq55SE_jczRtPcd26oSUkyP4cN1cSWkahr376w==?uid=0&filename=5a9971862127c.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              placeholderColor: #colorLiteral(red: 0.9722293019, green: 0.5698908567, blue: 0.003058324102, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Water Park Caribbean",
                                              description: "Water slides, open beaches, a bath complex, pools, game rooms, a fitness club ... and that's not all!",
                                              shortDescription: "Your have personal coupon",
                                              websiteLink: "https://karibiya.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/f5ac0db5efc54410e3a055acb6b7819db242167daf8c1d2f9cbce89a3f5d2708/5df48360/TybckqZp5gEYrj7pP-2uzjYbmtU11I2gfdbmks5rktuIV69KaPeyZ0CX9EsY8H_AVQAa-hoKyX-yyLQfH2hayA==?uid=0&filename=D3PO52-W4AEOm0k.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/9b73ee48dfb096886655aeae44e24bc9d5d13ed158b16355ce4f4ba6d5b7441d/5df4836b/W4KO5Woy3C3TxpBb1MvYi7659VQm2LWKxc_7mRyMN9d9Kgml6HZVUxsTdhWxsogQBajb9W_5D-Cm9mQCtUfmog==?uid=0&filename=3607966.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              placeholderColor: #colorLiteral(red: 0.998680532, green: 0.8855193257, blue: 0.002513965359, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Ozon",
                                              description: "OZON Online Store - Low Prices on Millions of Products! Electronics, clothing, cosmetics, books, pet supplies, products and more.",
                                              shortDescription: "Save your 25%",
                                              websiteLink: "https://www.ozon.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/3abc3ac653723a7b151efe76d79105dd5720f95fcfa01e7ae7d53f831c110447/5df48378/QezfO9G0xAP3bEL2nwXSuVu6z_WSy6pyyPnrT1vX5_HjbdMNRDYrcxGFQhnro_geY00zW26cCebff-vdjZZVTQ==?uid=0&filename=755053760199460.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/472028a1f4ff10c9e372b0f333ef1d2deb02428aa1be25d5f17e2ae11ccb4738/5df48382/H0e9hExupNIDENW96oX2glFxNLlvvTUuRBNEYGgXvfzcplfNBn6GcANITV7zeYntyDXSR932ONCRG6-rnlALfg==?uid=0&filename=5965117922.webp&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              placeholderColor: #colorLiteral(red: 0.007939346135, green: 0.7317495346, blue: 0.9377294183, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "AliExpress",
                                              description: "Sale of cell phones, computers, electronics, clothing, household goods, leisure and sports. Quick Guide and Buyer Tips.",
                                              shortDescription: "Save your 60%",
                                              websiteLink: "https://ru.aliexpress.com",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/ef9fe58dd356e68d6f8410b585805e66eb85b6655e7c19a3f775623e5327baa4/5df48392/RVblMKBmKvuIWfHQjkYFix3Z9js8j-L6tzRS1X1gJsDvFCT8AFP6yM1vCUSRoAx1hFIfpOOOIYjmGa-i69nZ6w==?uid=0&filename=maxresdefault.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/098ad45aceb091e519f80d346db44ce90e3cd7b5ef74a94bdc6df027ccefcba0/5df4839c/dgVD-jOage-D9azLWiGShRqK1FHyR9BKvR71pl4_0heuRYoPHzP4AGY61m5K8S07LE5nhGKc-tfPx-qPH-WHKg==?uid=0&filename=cf9552e8e3bec01637592240bef1c34c.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              placeholderColor: #colorLiteral(red: 0.8950105309, green: 0.1806768477, blue: 0.02160408907, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "ASOS",
                                              description: "Buy trendy clothes online at ASOS! A huge selection of stylish women's and men's clothing.",
                                              shortDescription: "Your have personal coupon",
                                              websiteLink: "https://www.asos.com/ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/33d2eb52b6f672d23e45e2de735866229b68cee96848b295589c571a9d45348f/5df483a6/581V6j1lYM9pYfN0J94gv6qb_nb1IsutzfsTcYoroylQJn7W7RuEIiwxbyvaPPSh1beVIHplK-anFfBfEqggRg==?uid=0&filename=AsosResponse2Big.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/bc6824089913aaa833a00d723bbe3f20eb1c109bef9daac0ac537cc1b280a787/5df483b2/F9whpKu8SNHaCcfZrUx6OdVXzrvWgRIPCHuT35Cl4zUXyVwe_3AqOn-aAD_VyhdDS3xT-T8ki7AjmtY3H0uo_g==?uid=0&filename=prodam-zhenskuyu-obuv-stok-asos-photo-771b.webp&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              placeholderColor: #colorLiteral(red: 0.1174927279, green: 0.1178211495, blue: 0.1089733914, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Amazon",
                                              description: "Low prices at Amazon on digital cameras, MP3, sports, books, music, DVDs, video games, home & garden and much more.",
                                              shortDescription: "Save your 30%",
                                              websiteLink: "https://www.amazon.co.uk",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/a8f5bd693aa3a8a67e51766496d3a27a4841bc1a809c2bdf1cbd3dae73e28782/5df483bc/ezoJKBfbHEAwg-xaPhjKAoSXLUIPEOOOsFS5-jiJX3ppA9YmVXTi-8Wc7tslUpT44p0g09CX_57CMzxalfg7dQ==?uid=0&filename=DBnCaOaUQAAGqfB.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/20c47c55ad21f7d28e16005a0ddc2f9f8e5b856e69cd7cf2de298e3b902b35f5/5df483cd/hf_jOaDvpeiD43_Hgwex5sUOlRurtpM0JPLyaa4j2Pgc80CLxTiGU0A8wfZNkz96-MmqsFey0DVCIekmXcVl9A==?uid=0&filename=EF3EY2uXkAAgujv.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              placeholderColor: #colorLiteral(red: 0.1396624744, green: 0.1249086931, blue: 0.1295438111, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Apple",
                                              description: "Check out Apple innovations. Choose and buy your iPhone, iPad, Apple Watch, Mac, and Apple TV.",
                                              shortDescription: "Special inventational",
                                              websiteLink: "https://www.apple.com",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/3cb8c96360be63b8a2b94f459b8ca3a9a8a99a29265c44aa68294df8dd8bb817/5df483d8/DpRDI94E66UO7DG6lp3PMBhH--gmvteO5XVcR4rBnSdkTXeLAoSjs3IawDMWsbfis9YMmxa6ad1ZsDVINaQaog==?uid=0&filename=9b30b445d128d9918da4b3ad5085881b_small.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/f9150280594f72c045e36edb00ebb47cf7a9bf711bdf031d86688b804b3b8709/5df483e3/_mLrDIbC3QMMaGk3dKAkLnYL-yWX_bgHYDVnAeGjsT1CDk9xWXgelh-i2FOAgVg6o1lEGLoCSmB7DDdAdsJnxA==?uid=0&filename=Apple-640x394.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              placeholderColor: #colorLiteral(red: 0.07493124157, green: 0.139801532, blue: 0.2554385662, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes)],
                             tags: []),
            ShopCategoryData(categoryName: "Food",
                             shops: [ShopData(name: "KFC",
                                              description: "Menu: chicken dishes, french fries, salads, snacks, etc.",
                                              shortDescription: "Two for one price",
                                              websiteLink: "https://www.kfc.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/bf3f0db3e4d7decb792f92e2bc8a22a9887bcbd39b89c2a9e4f72668765c8b4a/5df483ef/MTZjRERizdOYCQV_Cw0vbTxMl20AJcQdfTDysh7veYjhJn0B_VPpsWQDezSgFPXOrxfRBd8AbY95OMP6GxZaHA==?uid=0&filename=2-nhat-ban-kfc-5-1512005597643.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2400x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/fca6f7dc01ff7f8e32966bdc4f9376df7b22f10236289bb216b6fb4ec2f70389/5df484e6/yXXkYd-B9PpM7YZ2y59e6kMUT--RC7ozC04ESnpks99aKeqEcPleZCb5lQsjjGLdEhltqaNoPrtcjuJLhDy6NQ==?uid=0&filename=kfc-logo.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              placeholderColor: #colorLiteral(red: 0.6545341015, green: 0.1229880676, blue: 0.1732276082, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "McDonald's",
                                              description: "Most popular and common fast food chain in The USA and Canada",
                                              shortDescription: "New menu",
                                              websiteLink: "https://mcdonalds.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/cde83812c3931482e5c31ad7f464b8a76a242479f90606d3621a7f4db7073129/5df484f5/X9GswtIytjA_4r_ho5Nvdc1qqAyppncFLJmt2tRb2TKWpWNPHZGcPUiaeq7M-mexqKqcQAwr1tjnmebpjxRElQ==?uid=0&filename=mcdonald1.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/58b71eac74386c8584b431f6d088bc6970d89a734fd24e79279a2882868245cf/5df48500/kMHl5m4k91K6TnwMzp0KQBC0dGj0iNxzTi_dH4KynAgcS4eoqMXol0i2vL_Bctv7xKVK6O21YkyV-APOUM4rVw==?uid=0&filename=mcDonalds-Qs-e1526363465476.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              placeholderColor: #colorLiteral(red: 0.9977615476, green: 0.7533308864, blue: 0.01199052483, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Yakitoria",
                                              description: "Real Japanese and European cuisine with home delivery in Moscow!",
                                              shortDescription: "Save your 10%",
                                              websiteLink: "https://yakitoriya.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/71cec2a37e86edff123bc47cff911753d942a8f568feb43f575cc637434da9ef/5df48514/ZKpWnp9sEZJ92mHpNXlsiK_kRWWI14UeOAGkvmEvJrl_fhrN8Amr-TGA8U_m6ZO5s1S2BdQ-cS3vJj-SrkeosA==?uid=0&filename=23334055_1486303894779087_9040458936558208698_o.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/8f3508d4e01ddd259b290e57c7d48c6c4b15305dcf8e706b3f573f65a6a7bb91/5df48520/bmCekreu93sjQV62eCC0Q-mHx60BmWo8QwtBqZEJvDNeAdQ_N9AksGkWDOgYyuuzN-w9IAolbqzyOuhX5wq6FQ==?uid=0&filename=yakitoriya.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              placeholderColor: #colorLiteral(red: 0.9265739322, green: 0.1133742854, blue: 0.2094681561, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Papa Johns",
                                              description: "Pizzas, snacks, salads, desserts, drinks.",
                                              shortDescription: "New pizza",
                                              websiteLink: "https://www.papajohns.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/7bfe74a12c396f3003e800697a0aaa7c757d67f1a6ee5292efd4658ec01596b5/5df48563/OuKp9JfJikA5b8lAnSmGGc5nvxTjFvP_oFRyRcOm11H4m3LSdN07ceTzR6XXD0HJWZ8dMwv9FovR5nxqXC_X8g==?uid=0&filename=common.jpeg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/ffe615d75a425cd051b335d8c01ce456a851ce49ff515aefc22c781e925b341e/5df48570/Aqd8bzj205FHjVC4ano7SSdt9Z04CrseCjwATfHi9lGFYX-yAT77q1_TWP5Hu4Fe0rl7ScTfb9OhVOlROxro9g==?uid=0&filename=187649156_hflV0o2jNXzHrIKCqm_Ddq25hk0A0taUmA27ePvpv0I.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              placeholderColor: #colorLiteral(red: 0.01218329836, green: 0.5515415668, blue: 0.4193345606, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Burger King",
                                              description: "Burgers, snacks, salads, side dishes and desserts.",
                                              shortDescription: "Two for one price",
                                              websiteLink: "https://burgerking.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/c978404c70d2b8b0902badbff0aa5a8145b60d3a7ec0383c78a8250486a6e570/5df4857a/QxNujAZygSDy--59b2olo3_H2nKSNGlDGAYKuhYFe1s1VjyFQ7epa9tN6eEK4Cybn50jZDJviFZlQBVGhWRgHw==?uid=0&filename=burger-king-torres-novas.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/76ade641695b963fe45729ef99f94b9ac0e96ba2456b5dd850cd8f84317ad8a9/5df485bc/gMKZk6ioCov0vNGi_wT0wINUAnTn4XjxkDH19ojIgYybp7xrr4pWQ-jreniDL_OToUmm1P4-YGcVz7CPSgiUVg==?uid=0&filename=shutterstock_582770044-768x768.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              placeholderColor: #colorLiteral(red: 0.006101547275, green: 0.0716901049, blue: 0.4215092659, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes)],
                             tags: []),
            ShopCategoryData(categoryName: "Clothes",
                             shops: [ShopData(name: "Lamoda",
                                              description: "Catalog of women's, men's and children's clothing, shoes and accessories.",
                                              shortDescription: "New arrival",
                                              websiteLink: "https://www.lamoda.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/952b93be7529c0cc2471e5b0b8a43b086da073463a98c25dfa36a9db885ae7ab/5df485ca/-7071H6YRzRth1VKnLyv4Au7BdhSAsVt7Pf9pIx4hwfHcQP1pOxiXB8McWKYCr3LROnqFAsqcfXkhevOhb0D3w==?uid=0&filename=15-1.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/99d869626882b67830f689e06a80ef134f556ad003c5fb3b7e77c971c501c221/5df485d5/jNQGGXSACbVnFNLCFwQGWB376GD0STesGAgq-5WSTNFpo0qzJKnQjtLTUlUlIuV8svIOw0DKw8Za4IVObGwD3w==?uid=0&filename=lamoda_internet-magazin.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fpng&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              placeholderColor: #colorLiteral(red: 0.9977995753, green: 0.6786238551, blue: 0.7828680277, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Brandshop",
                                              description: "Sale of clothes, shoes and accessories Stone Island, New Balance, Barbour, Hackett, Maison Kitsune and other brands.",
                                              shortDescription: "Save your 30%",
                                              websiteLink: "https://brandshop.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/331e62958bc0151a6bdf25aa148c5a0ddd4a98e5676f947c0f57c9b2c0759940/5df485e1/x-0sme5W36tWNP2kGh5YUMtnrAJBkYzvtZj_Je5QWkCX3QENA0nJG46SpwFtWms-Mh7CTVpgaKuTdDhWj1F9OQ==?uid=0&filename=a4939bf5a55d087a51c6d376ce296af8.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/70b30feb2cb1af58fb05d0dd5f9f9da50e49c5da66fdaa9fd66362d2aefbf90c/5df485ea/j3G6FmyuzhTDfr2ABwmCoEva2vkeFzwbT4zvZhiE6H6UlZcsp9U50Z3i6nD22af1vrmtsE0LdK_n7wNBqteAnA==?uid=0&filename=mini-brandshop-novyj-logotip-532x326a.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              placeholderColor: #colorLiteral(red: 0.5764058232, green: 0.5765079856, blue: 0.5763992667, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Kiabi",
                                              description: "French brand of fashion for the whole family at low prices - Shop Online!",
                                              shortDescription: "Your have personal coupon",
                                              websiteLink: "https://www.kiabi.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/95fcfbdcf440579dc21ecefda1fb0df41d52841d4e7db047e0e4adb45816e2ee/5df48672/pFo7QFJj8LM7vbWJaGKapHelazrSIkKKkXI8V_rDb8wJQ9wgJYHyXLwzRKN5ewgWCpNcpI6L9G-fhtkvrLMP6g==?uid=0&filename=6fffb55f994659a7420d183b929bea47.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/a95d289eab93cf69ed4de20c29f3bcccfd56e04ae0f0b01c68a9d27c218ee466/5df48685/42gfAjAGxDII6CyAmxCDaPc3cWIAx6H13d61mWNpkUIOdhiEPo0xvrrk8AjTTIJlekEguLdHovuEhWiBhN64fA==?uid=0&filename=dop-kart_logotipi-kiabi.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              placeholderColor: #colorLiteral(red: 0.005735223647, green: 0, blue: 0.2101224959, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "WildBerries",
                                              description: "Collections of women's, men's and children's clothes, shoes, as well as goods for home and sports.",
                                              shortDescription: "Save your 10%",
                                              websiteLink: "https://www.wildberries.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/9ae077f3cb1b9e3ea9851e2f3cedb5682b88b98f13aa8f3df3576c7e9e6eb63a/5df48690/v653VGY3q8h1Hj_3pvm-9xRUZeyy9STTTeF85lj-3BytJ2LCov6bLQlhE_2SaqgUkY-z5Hk6oRlEArqENDB_7Q==?uid=0&filename=D09BD0BED0B3D0BED182.jpeg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/899a59c6e87d45af75015638fe41a4fb55932bc83941f01735405ab32e8bedc1/5df486d0/1RO3FSj1zOa5MD1aEd1ndw9_eE86iOKHvheSn65HpJzYc-qkkpPNWRk_24b5l10LZdTKSSgj4n7ioEbB7ow1vQ==?uid=0&filename=wildberries.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              placeholderColor: #colorLiteral(red: 0.7378610969, green: 0.2252326906, blue: 0.5863844156, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes)],
                             tags: []),
            ShopCategoryData(categoryName: "Cosmetics",
                             shops: [ShopData(name: "Pudra",
                                              description: "Sale of perfumes, decorative cosmetics, skin and hair care products.",
                                              shortDescription: "Your have personal coupon",
                                              websiteLink: "https://pudra.ru",
                                            imageLink: "https://downloader.disk.yandex.ru/preview/a1017f7261f5dcfc687d793aa22549189c1a0d5baa2433cbb53adbeb132eb998/5df486e2/YwUZVl0maKhgXKsOhHJNLm99uo4LqqlWaKXSIwEKIgBMJgxplCJmrCqcKhz0HCJqGJUMjfV1A43QncZt4T6Xcw==?uid=0&filename=scale_1200+%281%29.webp&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                            previewImageLink: "https://downloader.disk.yandex.ru/preview/64d16966b4aa60339a432335a4045c2386f5e21f9bf2d9d2741018d2a91cce14/5df486ee/zcaAjx6v_lcf9ASxoofINoecRe1WjILYO1ysFWLRl5-uAkkcA9d49VIbfGqP2_pQAy7ISarR8k00YsTH9M8Ufw==?uid=0&filename=pudra-promo.jpeg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                            placeholderColor: #colorLiteral(red: 0.9281816483, green: 0.7574380636, blue: 0.8091133237, alpha: 1),
                                            image: nil,
                                            previewImage: nil,
                                            isFavorite: false,
                                            promocodes: promocodes),
                                     ShopData(name: "L'Etoile",
                                              description: "Catalog of perfumes, decorative cosmetics, hair care products, face, body, etc.",
                                              shortDescription: "Save your 30%",
                                              websiteLink: "https://www.letu.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/7e0db3a31cac7b080fe6deb9be5839f38124e6e48ad0c708d2094588f537880d/5df486f8/SDAusJzo2B5JDfj-Y3MQDvUqHTbEndlCZXzX3CnRkSm4vP-e5hi5rdVcSsY7QoagVgd08pFrYRjPuIrTaCTqAA==?uid=0&filename=scale_1200+%282%29.webp&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/50a2dcf4ddb682e3ea4184fe4fb45d866d42d3f1417a9dfc910bac6e327f21df/5df48702/Mme4ItbgyxW0rgb0mAEcCgGpKX7hM7MPRNHi9E2I2zQn11muXzy2XXYrjtHn2LkC-q9emiiHcXUTumprKvPk8w==?uid=0&filename=_Letual_640h480.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              placeholderColor: #colorLiteral(red: 0.0472619012, green: 0.1629578173, blue: 0.4771181941, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Makeup market",
                                              description: "Online store of care, decorative, professional cosmetics and perfumes Makeup market.",
                                              shortDescription: "Save your 10%",
                                              websiteLink: "https://makeupmarket.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/11d6fa47ef83731466457035957ce7856f94a5e9f06bb2f34b6c688955d0d563/5df48711/OrOPFgBoFxs1OfdGTsVbzQ6bViD1IP_EriU9RxAtGYAnpRnTBShvUrCowePL0oVObScy3g9j5raQNYZHQ-IJoA==?uid=0&filename=mejk-ap-market-kupon.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/387591d83a7ff7fb0f8b0cf4bf3622c5a3fd652189b993930eb50e045d8fedea/5df4871a/E61RMfwo31EM-UTU0s7Owl78ZzyV4RJAnmtZ41xh8lTRmc_5rwAbw4kaejUryB4xuUnbvYyLeMcugE4oZV9y3Q==?uid=0&filename=logo.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              placeholderColor: #colorLiteral(red: 0.9998916984, green: 1, blue: 0.9998806119, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Gracy",
                                              description: "Sale of decorative cosmetics, face and body care products, perfumes, etc.",
                                              shortDescription: "New arrival",
                                              websiteLink: "https://gracy.ru",
                                              imageLink: "https://downloader.disk.yandex.ru/preview/5a7925a69ad0e2038e0ac94b3bf22923ba5fb45b18ca84b2ff57eef9f7b61f90/5df48729/CSimhLCXPz-JG3-n_5lrwtQ_Sj0FYEe72_F-5EpubAC2IA_gPoKprN3jC_QjCUpogrvbCLuiggFMOs6_-NLdfw==?uid=0&filename=3deb5285c82b6f68259f720800da6a23.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              previewImageLink: "https://downloader.disk.yandex.ru/preview/3e961cecd04faae79040fa3702184a20b9d8908dfa8110ccb74b3f9138e56133/5df48782/IYzzhf8Jg1On1FWrnBxbAoI-q-QWh3lMj5_WwgvD5M8fzY6n4MinKeHh9oZRUu9SexQnkQu8lNjOnqpISPzdDA==?uid=0&filename=IMG_4789.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&tknv=v2&owner_uid=158062514&size=2732x1294",
                                              placeholderColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes)],
                             tags: [])
        ]
        self.collections = collections
        
//        let promocodes = [
//                PromocodeData(coupon: "COUPON30",
//                              addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 3),
//                              estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 7),
//                              description: "Save your 30% when spent more than 5000",
//                              isHot: false),
//                PromocodeData(coupon: "COUPON20",
//                              addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 2),
//                              estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 6),
//                              description: "Amazing discounts up to 20% on sale!",
//                              isHot: false),
//                PromocodeData(coupon: "COUPON10",
//                              addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 1),
//                              estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 5),
//                              description: "Save your 10% when spent more than 1000",
//                              isHot: false),
//                PromocodeData(coupon: "COUPON40",
//                              addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 3),
//                              estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 4),
//                              description: "The promotional code for an additional discount of 40%.",
//                              isHot: false),
//                PromocodeData(coupon: "COUPON50",
//                              addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 3),
//                              estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 3),
//                              description: "The promotional code for an additional discount of 50%.",
//                              isHot: false),
//                PromocodeData(coupon: "COUPON60",
//                              addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 1),
//                              estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 2),
//                              description: "Amazing discounts up to 60% on sale!",
//                              isHot: false),
//                PromocodeData(coupon: "COUPON70",
//                              addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 1),
//                              estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 1),
//                              description: "Save your 70% when spent more than 15000",
//                              isHot: false),
//                PromocodeData(coupon: "COUPON80",
//                              addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 1),
//                              estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 1),
//                              description: "Amazing discounts up to 80% on sale!",
//                              isHot: false),
//                PromocodeData(coupon: "COUPON90",
//                              addingDate: Date(timeIntervalSinceNow: -60 * 60 * 24 * 1),
//                              estimatedDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 1),
//                              description: "Amazing discounts up to 90% on sale!",
//                              isHot: false)
//        ]
//        collections = [
//            ShopCategoryData(categoryName: "HOT 🔥",
//                            shops: [ShopData(image: UIImage(named: "Delivery"),
//                                             name: "Delivery Club",
//                                             shortDescription: "Save your 35%",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "Yandex"),
//                                             name: "Yandex Food",
//                                             shortDescription: "Save your 15%",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "WaterPark"),
//                                             name: "Water Park Caribbean",
//                                             shortDescription: "Your have personal coupon",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "Ozon"),
//                                             name: "Ozon",
//                                             shortDescription: "Save your 25%",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "AliExpress"),
//                                             name: "AliExpress",
//                                             shortDescription: "Save your 60%",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "ASOS"),
//                                             name: "ASOS",
//                                             shortDescription: "Your have personal coupon",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "Amazon"),
//                                             name: "Amazon",
//                                             shortDescription: "Save your 30%",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "Apple"),
//                                             name: "Apple",
//                                             shortDescription: "Special inventational",
//                                             placeholderColor: UIColor.red)]),
//            ShopCategoryData(categoryName: "Food",
//                            shops: [ShopData(image: UIImage(named: "KFC"),
//                                             name: "KFC",
//                                             shortDescription: "Two for one price",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "McDonald's"),
//                                             name: "McDonald's",
//                                             shortDescription: "New menu",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "Yakitoria"),
//                                             name: "Yakitoria",
//                                             shortDescription: "Save your 10%",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "KFC"),
//                                             name: "KFC",
//                                             shortDescription: "Two for one price",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "McDonald's"),
//                                             name: "McDonald's",
//                                             shortDescription: "New menu",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "McDonald's"),
//                                             name: "McDonald's",
//                                             shortDescription: "New menu",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "Yakitoria"),
//                                             name: "Yakitoria",
//                                             shortDescription: "Save your 10%",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "KFC"),
//                                             name: "KFC",
//                                             shortDescription: "Two for one price",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "McDonald's"),
//                                             name: "McDonald's",
//                                             shortDescription: "New menu",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "McDonald's"),
//                                             name: "McDonald's",
//                                             shortDescription: "New menu",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "Yakitoria"),
//                                             name: "Yakitoria",
//                                             shortDescription: "Save your 10%",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "KFC"),
//                                             name: "KFC",
//                                             shortDescription: "Two for one price",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "McDonald's"),
//                                             name: "McDonald's",
//                                             shortDescription: "New menu",
//                                             placeholderColor: UIColor.red),
//                                    ShopData(image: UIImage(named: "Yakitoria"),
//                                             name: "Yakitoria",
//                                             shortDescription: "Save your 10%",
//                                             placeholderColor: UIColor.red)]),
//            ShopCategoryData(categoryName: "Other",
//                             shops: [ShopData(image: UIImage(named: "Amazon"),
//                                             name: "Amazon",
//                                             shortDescription: "Save your 30%",
//                                             placeholderColor: UIColor.red),
//                                     ShopData(image: UIImage(named: "Apple"),
//                                             name: "Apple",
//                                             shortDescription: "Special inventational",
//                                             placeholderColor: UIColor.red),
//                                     ShopData(image: UIImage(named: "AliExpress"),
//                                             name: "AliExpress",
//                                             shortDescription: "Save your 60%",
//                                             placeholderColor: UIColor.red),
//                                     ShopData(image: UIImage(named: "ASOS"),
//                                             name: "ASOS",
//                                             shortDescription: "Your have personal coupon",
//                                             placeholderColor: UIColor.red)])
//        ]
//        collections.forEach { category in
//            category.shops.forEach { shop in
//                shop.promocodes.append(contentsOf: promocodes)
//            }
//        }
    }
}

    // MARK: - Home Section Data Controller
extension ModelController {
    
    static private func createHomeDataController() -> HomeDataController {
        
        let controller = HomeDataController()
        
        return controller
    }
    
//    static private func updateHomeCollections() {
//
//        _homeCollections = collections.reduce(into: [ShopCategoryData]()){ result, section in
//
//            let shops = Array(section.shops.prefix(15))
//
//            let reducedSection = ShopCategoryData(categoryName: section.categoryName,
//                                             shops: shops)
//
//            result.append(reducedSection)
//        }
//    }
    
}

    // MARK: - Favorites Section Data Controller

extension ModelController {
    
    static private func updateFavoritesCollections() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let favoritesCollections = collections.reduce(into: [ShopCategoryData]()) { result, section in
                let shops = section.shops.filter { $0.isFavorite }
                if !shops.isEmpty {
                    let newSection = ShopCategoryData(categoryName: section.categoryName, shops: shops, tags: [])
                    result.append(newSection)
                }
            }.sorted { $0.categoryName < $1.categoryName }
            //NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
            self.favoritesCollections = favoritesCollections
            favoritesDataController.collectionsBySections = favoritesCollections
        }
    }
    
    static func updateFavoritesCollections(with collections: [ShopCategoryData]) {
        
        favoritesCollections = collections
        NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
    }
    
    static func insertInFavorites(shop: ShopData) {
        
        let section = collections.first { section in
            if section.shops.contains(shop) {
                return true
            }
            return false
        }
        
        if let sectionIndex = favoritesCollections.firstIndex(where: { $0.categoryName == section!.categoryName }) {
            favoritesCollections[sectionIndex].shops.append(shop)
        } else {
            favoritesCollections.append(ShopCategoryData(categoryName: section!.categoryName, shops: [shop]))
            favoritesCollections.sort { $0.categoryName < $1.categoryName }
        }
        
        NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
        favoritesDataController.collectionsBySections = favoritesCollections
    }
    
    static func deleteFromFavorites(shop: ShopData) {
        
        let section = collections.first { section in
            if section.shops.contains(shop) {
                return true
            }
            return false
        }
        
        if let sectionIndex = favoritesCollections.firstIndex(where: { $0.categoryName == section!.categoryName }) {
            if let removeIndex = favoritesCollections[sectionIndex].shops.firstIndex(where: { $0.identifier == shop.identifier }) {
                favoritesCollections[sectionIndex].shops.remove(at: removeIndex)
            }
            
            if favoritesCollections[sectionIndex].shops.isEmpty {
                favoritesCollections.remove(at: sectionIndex)
                favoritesCollections.sort { $0.categoryName < $1.categoryName }
            }
        }
        
        NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
        favoritesDataController.collectionsBySections = favoritesCollections
    }
    
    static func updateFavoritesCollections(in name: String, with addedCells: Set<ShopData> = []) {
            
        if let sectionIndex = favoritesCollections.firstIndex(where: { $0.categoryName == name }) {
            let section = favoritesCollections[sectionIndex]
            
            var reduced = section.shops.filter { cell in
                if addedCells.contains(cell) {
                    return false
                }
                
                return cell.isFavorite
            }
            
            reduced.append(contentsOf: addedCells)
            
            if reduced.isEmpty {
                favoritesCollections.remove(at: sectionIndex)
            } else {
                section.shops = reduced
            }
            
        } else {
            favoritesCollections.append(ShopCategoryData(categoryName: name, shops: Array(addedCells)))
        }
        
        favoritesCollections.sort { $0.categoryName < $1.categoryName }
        favoritesDataController.collectionsBySections = favoritesCollections

        
    }
    
    static func removeAllFavorites() {
        
        guard !favoritesCollections.isEmpty else {
            return
        }
        
        favoritesCollections.forEach { section in
            section.shops.forEach { cell in
                cell.isFavorite = false
            }
        }
        favoritesCollections = []
        favoritesDataController.collectionsBySections = []
        NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
    }
    
    static private func createFavoritesDataController() -> FavoritesDataController {
        
        let controller = FavoritesDataController(collections: favoritesCollections)
        
        return controller
    }
}

    // MARK: - Search Data

extension ModelController {
    
    static private func setupSearchData() -> ShopCategoryData {
        
        let shops = collections.reduce(into: [ShopData]()) { result, section in
            result.append(contentsOf: section.shops)
        }
        
        return ShopCategoryData(categoryName: "Search", shops: shops)
    }
}
