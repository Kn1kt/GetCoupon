//
//  Model.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 25.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import Network

class ModelController {
    
    /// Main Collection
    static private var needSaveToStorage: Bool = false
    static private var needSaveFavoritesToStorage: Bool = false
    
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
                //updateFavoritesCollections()
                loadFavoritesCollectionsFromStorage()
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
            needSaveFavoritesToStorage = true
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
        let queue = DispatchQueue(label: "monitor")
        let monitor = NWPathMonitor()
        monitor.start(queue: queue)
        
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 1) {
            guard monitor.currentPath.status == .satisfied,
                let url = URL(string: "https://www.dropbox.com/s/qge216pbfilhy08/collections.json?dl=1") else {
                    
                    loadCollectionsFromStorage()
                    return
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedCollections = try jsonDecoder.decode([ShopCategoryData].self, from: data)
                    collections = decodedCollections
                } catch {
                    debugPrint(error)
                }
            }.resume()
        }
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
            
            debugPrint("loaded Collections to storage")
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
                //generateCollections()
            }
            
            debugPrint("loaded Collections from storage")
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
        
        collections.forEach { category in
            category.shops.forEach { shop in
                shop.image = nil
                shop.previewImage = nil
            }
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
                                              imageLink: "https://www.dropbox.com/s/uswacg6smwzzfh2/resize_903_635_true_crop_903_635_0_0_q90_77432_a936f3fbad.jpeg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/u7ntgf6cz7zst3m/IBrWLeJ3jT0.jpg?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.6835173368, green: 0.8750453591, blue: 0.1662097871, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Yandex Food",
                                              description: "Order food from restaurants - fast delivery in 45 minutes.",
                                              shortDescription: "Save your 15%",
                                              websiteLink: "https://eda.yandex",
                                              imageLink: "https://www.dropbox.com/s/v8cc850t5pb0kfq/68.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/esgy5zz2sykoahb/5a9971862127c.png?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.9722293019, green: 0.5698908567, blue: 0.003058324102, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Water Park Caribbean",
                                              description: "Water slides, open beaches, a bath complex, pools, game rooms, a fitness club ... and that's not all!",
                                              shortDescription: "Your have personal coupon",
                                              websiteLink: "https://karibiya.ru",
                                              imageLink: "https://www.dropbox.com/s/wx31aczt904w0j4/D3PO52-W4AEOm0k.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/35x1x53a9gce6qp/3607966.png?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.998680532, green: 0.8855193257, blue: 0.002513965359, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Ozon",
                                              description: "OZON Online Store - Low Prices on Millions of Products! Electronics, clothing, cosmetics, books, pet supplies, products and more.",
                                              shortDescription: "Save your 25%",
                                              websiteLink: "https://www.ozon.ru",
                                              imageLink: "https://www.dropbox.com/s/bzx8jo302h1xrvk/755053760199460.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/anxoh05tdi6a5oh/20190131133205710.jpg?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.007939346135, green: 0.7317495346, blue: 0.9377294183, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "AliExpress",
                                              description: "Sale of cell phones, computers, electronics, clothing, household goods, leisure and sports. Quick Guide and Buyer Tips.",
                                              shortDescription: "Save your 60%",
                                              websiteLink: "https://ru.aliexpress.com",
                                              imageLink: "https://www.dropbox.com/s/fnz83g1c2teocfd/maxresdefault.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/uj7hur8tnx4n2kd/cf9552e8e3bec01637592240bef1c34c.jpg?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.8950105309, green: 0.1806768477, blue: 0.02160408907, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "ASOS",
                                              description: "Buy trendy clothes online at ASOS! A huge selection of stylish women's and men's clothing.",
                                              shortDescription: "Your have personal coupon",
                                              websiteLink: "https://www.asos.com/ru",
                                              imageLink: "https://www.dropbox.com/s/41zsyat5f3gog6v/AsosResponse2Big.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/zzlelqzjefmg9ad/512x512bb.jpg?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.1174927279, green: 0.1178211495, blue: 0.1089733914, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Amazon",
                                              description: "Low prices at Amazon on digital cameras, MP3, sports, books, music, DVDs, video games, home & garden and much more.",
                                              shortDescription: "Save your 30%",
                                              websiteLink: "https://www.amazon.co.uk",
                                              imageLink: "https://www.dropbox.com/s/lkwaugwwmiv51iw/DBnCaOaUQAAGqfB.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/9cswpzfwxlw9m76/EF3EY2uXkAAgujv.jpg?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.1396624744, green: 0.1249086931, blue: 0.1295438111, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Apple",
                                              description: "Check out Apple innovations. Choose and buy your iPhone, iPad, Apple Watch, Mac, and Apple TV.",
                                              shortDescription: "Special inventational",
                                              websiteLink: "https://www.apple.com",
                                              imageLink: "https://www.dropbox.com/s/4eg6x0e5o1zk834/9b30b445d128d9918da4b3ad5085881b_small.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/tqifk9isrwbiywd/Apple-640x394.jpg?dl=1",
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
                                              imageLink: "https://www.dropbox.com/s/7o85cb5h37ws839/2-nhat-ban-kfc-5-1512005597643.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/0iq6iu2lvrq8bpq/kfc-logo.png?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.6545341015, green: 0.1229880676, blue: 0.1732276082, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "McDonald's",
                                              description: "Most popular and common fast food chain in The USA and Canada",
                                              shortDescription: "New menu",
                                              websiteLink: "https://mcdonalds.ru",
                                              imageLink: "https://www.dropbox.com/s/2hwz46jjos9f12v/mcdonald1.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/y1a9794mjmcwmds/mcDonalds-Qs-e1526363465476.jpg?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.9977615476, green: 0.7533308864, blue: 0.01199052483, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Yakitoria",
                                              description: "Real Japanese and European cuisine with home delivery in Moscow!",
                                              shortDescription: "Save your 10%",
                                              websiteLink: "https://yakitoriya.ru",
                                              imageLink: "https://www.dropbox.com/s/uswacg6smwzzfh2/resize_903_635_true_crop_903_635_0_0_q90_77432_a936f3fbad.jpeg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/e3j0ir1o9wyvo1v/yakitoriya.png?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.9265739322, green: 0.1133742854, blue: 0.2094681561, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Papa Johns",
                                              description: "Pizzas, snacks, salads, desserts, drinks.",
                                              shortDescription: "New pizza",
                                              websiteLink: "https://www.papajohns.ru",
                                              imageLink: "https://www.dropbox.com/s/zehgbalqgzgojjg/common.jpeg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/wn0v3nc2ahqxlin/187649156_hflV0o2jNXzHrIKCqm_Ddq25hk0A0taUmA27ePvpv0I.jpg?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.01218329836, green: 0.5515415668, blue: 0.4193345606, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Burger King",
                                              description: "Burgers, snacks, salads, side dishes and desserts.",
                                              shortDescription: "Two for one price",
                                              websiteLink: "https://burgerking.ru",
                                              imageLink: "https://www.dropbox.com/s/x2y7l782cpd8bq8/burger-king-torres-novas.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/kfwb4t37qylse40/shutterstock_582770044-768x768.png?dl=1",
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
                                              imageLink: "https://www.dropbox.com/s/4unhccztip0nq3t/15-1.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/n5zi44xm80bv0ik/lamoda_internet-magazin.jpg?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.9977995753, green: 0.6786238551, blue: 0.7828680277, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Brandshop",
                                              description: "Sale of clothes, shoes and accessories Stone Island, New Balance, Barbour, Hackett, Maison Kitsune and other brands.",
                                              shortDescription: "Save your 30%",
                                              websiteLink: "https://brandshop.ru",
                                              imageLink: "https://www.dropbox.com/s/ajx6pt0po6otep6/a4939bf5a55d087a51c6d376ce296af8.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/he0jgxjx5aoom70/mini-brandshop-novyj-logotip-532x326a.jpg?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.5764058232, green: 0.5765079856, blue: 0.5763992667, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Kiabi",
                                              description: "French brand of fashion for the whole family at low prices - Shop Online!",
                                              shortDescription: "Your have personal coupon",
                                              websiteLink: "https://www.kiabi.ru",
                                              imageLink: "https://www.dropbox.com/s/lc8b64r1nxsc1d4/6fffb55f994659a7420d183b929bea47.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/rm9o7bgpsn0phfh/dop-kart_logotipi-kiabi.jpg?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.005735223647, green: 0, blue: 0.2101224959, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "WildBerries",
                                              description: "Collections of women's, men's and children's clothes, shoes, as well as goods for home and sports.",
                                              shortDescription: "Save your 10%",
                                              websiteLink: "https://www.wildberries.ru",
                                              imageLink: "https://www.dropbox.com/s/pkg5zyo29rfayj6/D09BD0BED0B3D0BED182.jpeg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/6n00z5g7t8n2z9p/wildberries.jpg?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.7378610969, green: 0.2252326906, blue: 0.5863844156, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes)],
                             tags: []),
            ShopCategoryData(categoryName: "Cosmetics",
                             shops: [ShopData(name: "Gracy",
                                              description: "Sale of decorative cosmetics, face and body care products, perfumes, etc.",
                                              shortDescription: "New arrival",
                                              websiteLink: "https://gracy.ru",
                                              imageLink: "https://www.dropbox.com/s/0vrj6cncwdy98m8/IMG_4789.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/pqekumjznii7ex9/6421156.jpg?dl=1",
                                              placeholderColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "L'Etoile",
                                              description: "Catalog of perfumes, decorative cosmetics, hair care products, face, body, etc.",
                                              shortDescription: "Save your 30%",
                                              websiteLink: "https://www.letu.ru",
                                              imageLink: "https://www.dropbox.com/s/ru77ib5y9fzy99k/3deb5285c82b6f68259f720800da6a23.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/oepqpgf4tmr7ohh/_Letual_640h480.jpg?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.0472619012, green: 0.1629578173, blue: 0.4771181941, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Makeup market",
                                              description: "Online store of care, decorative, professional cosmetics and perfumes Makeup market.",
                                              shortDescription: "Save your 10%",
                                              websiteLink: "https://makeupmarket.ru",
                                              imageLink: "https://www.dropbox.com/s/2gr21did6j2tb4w/mejk-ap-market-kupon.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/3izlcti6e9vs6cs/logo.png?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.9998916984, green: 1, blue: 0.9998806119, alpha: 1),
                                              image: nil,
                                              previewImage: nil,
                                              isFavorite: false,
                                              promocodes: promocodes),
                                     ShopData(name: "Pudra",
                                              description: "Sale of perfumes, decorative cosmetics, skin and hair care products.",
                                              shortDescription: "Your have personal coupon",
                                              websiteLink: "https://pudra.ru",
                                              imageLink: "https://www.dropbox.com/s/551snb4uja2fi7r/1168-posts.facebook_lg.jpg?dl=1",
                                              previewImageLink: "https://www.dropbox.com/s/nvnslgofxqfdlrx/pudra-promo.jpeg?dl=1",
                                              placeholderColor: #colorLiteral(red: 0.9281816483, green: 0.7574380636, blue: 0.8091133237, alpha: 1),
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
    
    static private func updateFavoritesCollections(storedCollection: [ShopCategoryData]) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let favoritesCollections = collections.reduce(into: [ShopCategoryData]()) { result, section in
                guard let storedSection = storedCollection.first(where: { $0.categoryName == section.categoryName }) else {
                    return
                }
                
                let shops = section.shops.filter { shop in
                    if let storedShop = storedSection.shops.first(where: { $0.name == shop.name }) {
                        shop.isFavorite = true
                        shop.favoriteAddingDate = storedShop.favoriteAddingDate
                        return true
                    }
                    return false
                }
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
    
    static func loadFavoritesCollectionsToStorage() {
        
        guard needSaveFavoritesToStorage else {
            return
        }
        
        //DispatchQueue.global(qos: .background).async {
            
            let directoryURL = FileManager.default.urls(for: .cachesDirectory,
                in: .userDomainMask).first
            let fileURL = URL(fileURLWithPath: "favoritesCollections", relativeTo: directoryURL).appendingPathExtension("json")
            do {
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(favoritesCollections)
                try jsonData.write(to: fileURL, options: .noFileProtection)
            } catch {
                debugPrint(error)
            }
            
            debugPrint("loaded favoritesCollections to storage")
        //}
    }
    
    static func loadFavoritesCollectionsFromStorage() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let directoryURL = FileManager.default.urls(for: .cachesDirectory,
                in: .userDomainMask).first
            let fileURL = URL(fileURLWithPath: "favoritesCollections", relativeTo: directoryURL).appendingPathExtension("json")
            do {
                
                let jsonDecoder = JSONDecoder()
                let jsonData = try Data(contentsOf: fileURL)
                let decodedCollections = try jsonDecoder.decode([ShopCategoryData].self, from: jsonData)
                updateFavoritesCollections(storedCollection: decodedCollections)
            } catch {
                debugPrint(error)
            }
            
            debugPrint("loaded favoritesCollections from storage")
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
        
//        let directoryURL = FileManager.default.urls(for: .cachesDirectory,
//                                                    in: .userDomainMask).first
//        let fileURL = URL(fileURLWithPath: "favoritesCollections", relativeTo: directoryURL).appendingPathExtension("json")
//        do {
//            try FileManager.default.removeItem(at: fileURL)
//        } catch {
//            debugPrint(error)
//        }
//        needSaveFavoritesToStorage = false
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
