//
//  AppDelegate.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 03/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        let dvc = FoldersListConfigurator.configureModule()
        window?.rootViewController = UINavigationController(rootViewController: dvc)
        window?.makeKeyAndVisible()
        return true
    }
}
