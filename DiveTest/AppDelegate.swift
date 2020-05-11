//
//  AppDelegate.swift
//  DiveTest
//
//  Created by DIAKO on 5/11/20.
//  Copyright © 2020 Diako. All rights reserved.
//
import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let tabBarController = UITabBarController()
        let feed = NewsController()
        let bookmarks = BookmarksController()
        bookmarks.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "bookmarksTabbar"), selectedImage: UIImage(named: "bookmarksTabbarActive"))
        feed.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "menuTabbar"), selectedImage: UIImage(named: "menuTabbarActive"))
        let controllers = [feed, bookmarks]
        tabBarController.tabBar.tintColor = Colors.mainColor
        tabBarController.tabBar.unselectedItemTintColor = Colors.mainColor
        tabBarController.tabBar.barTintColor = .white
        tabBarController.viewControllers = controllers.map { UINavigationController(rootViewController: $0) }
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {
        DataManager.shared.saveContext()
    }
}

