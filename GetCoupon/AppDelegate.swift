//
//  AppDelegate.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 19.10.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let realm = try! Realm()
        let fpromo = PromoCodeStoredData(coupon: "SALE10", addingDate: Date(timeIntervalSinceNow: 0), estimatedDate: nil, description: "It is just TEST", isHot: true)
        let shop1 = ShopStoredData(name: "TEST", shortDescription: "short description", websiteLink: "link", promoCodes: [fpromo])
        let shop2 = ShopStoredData(name: "TEST2", shortDescription: "short description", websiteLink: "link", promoCodes: [fpromo])
        let category1 = ShopCategoryStoredData(categoryName: "TEST", shops: [shop1])
        let category2 = ShopCategoryStoredData(categoryName: "TEST2", shops: [shop2])
        let cache = CacheController()
        cache.append(categories: [category1, category2])

        if let storedCategory = realm.object(ofType: ShopCategoryStoredData.self, forPrimaryKey: "TEST") {
            print(storedCategory.description)
        }
        if let storedCategory = realm.object(ofType: ShopCategoryStoredData.self, forPrimaryKey: "TEST2") {
            print(storedCategory.description)
        }
        try! realm.write {
            shop1.shopDescription = "NEW-DESCRIPTION"
        }
        
        cache.update(category: category2, with: [shop1, shop2])
        
        if let storedCategory = realm.object(ofType: ShopCategoryStoredData.self, forPrimaryKey: "TEST") {
            print(storedCategory.description)
        }
        if let storedCategory = realm.object(ofType: ShopCategoryStoredData.self, forPrimaryKey: "TEST2") {
            print(storedCategory.description)
        }
//        let encoder = JSONEncoder()
//        let jsonData = try! encoder.encode(category)
//        let jsonData = try! encoder.encode(shop)
//        let decoder = JSONDecoder()
//        let jsonCategory = try! decoder.decode(ShopCategoryStoredData.self, from: jsonData)
//        let jsonShop = try! decoder.decode(ShopStoredData.self, from: jsonData)
//        print(jsonShop.description)
//        print(category.description)
//        print(jsonCategory.description)
        
//        try! realm.write {
//            category.shops.forEach {
//                $0.promoCodes.forEach {
//                    realm.delete($0)
//                }
//                //$0.promoCodes.removeAll()
//                realm.delete($0)
//            }
//            realm.delete(category)
//        }
//
//        if let _ = realm.object(ofType: ShopStoredData.self, forPrimaryKey: "TEST") {
//            print("Exist")
//        } else {
//            print("Kinda absence")
//        }
        try! realm.write {
            realm.deleteAll()
        }
        
        ModelController.updateCollections()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        ModelController.loadFavoritesCollectionsToStorage()
        ModelController.loadCollectionsToStorage()
    }
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "GetCoupon")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

