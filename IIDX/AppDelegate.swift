//
//  AppDelegate.swift
//  IIDX
//
//  Created by umeme on 2019/08/27.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Realmマイグレーション
        var config = Realm.Configuration()
        config.migrationBlock = { migration, oldSchemaVersion in
            
//            // wikiのタイトルが変更された曲対応
//            migration.enumerateObjects(ofType: MyScore.className()) { (oldObject, newObject) in
//                var title = oldObject!["title"] as! String
//                if (title == "Blind Justice 〜Torn souls, Hurt Faiths〜") {
//                    title = "Blind Justice ～Torn souls, Hurt Faiths～"
//                }
//            }
            
            // MyScore,OldScore,RivalScoreのmissCountをStringからIntに変更
            if oldSchemaVersion < 2 {
                migration.enumerateObjects(ofType: MyScore.className()) { (oldObject, newObject) in
                    var missCount = oldObject!["missCount"] as! String
                    if missCount == Const.Label.Score.HYPHEN {
                        missCount = "9999"
                    }
                    newObject!["missCount"] = Int(missCount)
                }
                migration.enumerateObjects(ofType: OldScore.className()) { (oldObject, newObject) in
                    var missCount = oldObject!["missCount"] as! String
                    if missCount == Const.Label.Score.HYPHEN {
                        missCount = "9999"
                    }
                    newObject!["missCount"] = Int(missCount)
                }
                migration.enumerateObjects(ofType: RivalScore.className()) { (oldObject, newObject) in
                    var missCount = oldObject!["missCount"] as! String
                    if missCount == Const.Label.Score.HYPHEN {
                        missCount = "9999"
                    }
                    newObject!["missCount"] = Int(missCount)
                }
            }
        }
        config.schemaVersion = UInt64(Const.Realm.SCHEMA_VER)
        Realm.Configuration.defaultConfiguration = config
        
        // Launch画面で１秒まつ
        sleep(1)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

