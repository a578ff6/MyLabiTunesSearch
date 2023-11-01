//
//  AppDelegate.swift
//  MyLabiTunesSearch
//
//  Created by 曹家瑋 on 2023/11/1.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    // 會在 App 啟動完成後被呼叫。
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 設定全局 URLCache 的記憶體緩存容量為 25MB。
        // App 可以將最多 25MB 的資料儲存在 RAM 中，這樣的資料可以更快被存取。
        URLCache.shared.memoryCapacity = 25_000_000
        
        // 設定全局 URLCache 的硬碟快緩存量為 50MB。
        // App 可以將最多 50MB 的資料儲存在硬碟上，即使App被關閉或裝置重新啟動後，這些資料也能被保留。
        URLCache.shared.diskCapacity = 50_000_000

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


}

