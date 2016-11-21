//
//  AppDelegate.swift
//  SlideMenuExample
//
//  Created by Евгений Матвиенко on 11/14/16.
//  Copyright © 2016 SilverDefender. All rights reserved.
//

import UIKit
import SideMenu

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let sideMenuController = SideMenuController()
        sideMenuController.dimColor = UIColor.white
        let menuExampleViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()! as! MenuExampleViewController
        sideMenuController.set(menuViewController: menuExampleViewController)
        
        let window = UIWindow()
        window.rootViewController = sideMenuController
        window.makeKeyAndVisible()
        self.window = window
        
        let vc1 = ViewController()
        vc1.title = "VC #1"
        vc1.view.backgroundColor = UIColor.red
        let nav1 = UINavigationController(rootViewController: vc1)
        
        let vc2 = ViewController()
        vc2.title = "VC #2"
        vc2.view.backgroundColor = UIColor.blue
        let nav2 = UINavigationController(rootViewController: vc2)
        
        let vc3 = ViewController()
        vc3.title = "VC #3"
        vc3.view.backgroundColor = UIColor.green
        let nav3 = UINavigationController(rootViewController: vc3)
        
        sideMenuController.viewControllers = [nav1, nav2, nav3]
        sideMenuController.present(viewControllerAtIndex: 0, animated: false)
        
        return true
    }


}

