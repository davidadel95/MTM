//
//  AppDelegate.swift
//  MTM
//
//  Created by David Adel on 03/02/2021.
//

import UIKit
import Firebase
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainController = HomeVC() as UIViewController
        let navigationController = UINavigationController(rootViewController: mainController)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.isHidden = true
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyB6RYZkcGKumvHuKMuUBTFXlpKEWorfo_c")
        
        return true
    }

}

