//
//  AppDelegate.swift
//  ZZReaderViewControllerExample
//
//  Created by Ethan on 2022/11/2.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = ExampleNavigationController(rootViewController: HomeViewController())
        return true
    }

}
