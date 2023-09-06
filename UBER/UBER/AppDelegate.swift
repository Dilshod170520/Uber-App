//
//  AppDelegate.swift
//  UBER
//
//  Created by MacBook Pro on 05/09/23.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
        var window: UIWindow?
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.
            FirebaseApp.configure()
            window = UIWindow()
            window?.makeKeyAndVisible()
           
            window?.rootViewController = UINavigationController(rootViewController: LoginController())
            return true
        }
}

