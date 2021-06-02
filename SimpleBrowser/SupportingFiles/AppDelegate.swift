//
//  AppDelegate.swift
//  SimpleBrowser
//
//  Created by Laura Esaian on 01.06.2021.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        let navigationCintroller = UINavigationController(rootViewController: BrowserViewController())
        window?.rootViewController = navigationCintroller
        window?.makeKeyAndVisible()
        
        return true
    }
}

