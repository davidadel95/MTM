//
//  AppDelegate.swift
//  MTM
//
//  Created by David Adel on 03/02/2021.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import SideMenuSwift
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        SideMenuController.preferences.basic.menuWidth = (self.window?.frame.width)! * 2/3
        SideMenuController.preferences.basic.direction = .left
        
        let mainController = SideMenuController(contentViewController: HomeVC(), menuViewController: SideMenuVC()) as UIViewController
        let navigationController = UINavigationController(rootViewController: mainController)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.isHidden = true
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyB6RYZkcGKumvHuKMuUBTFXlpKEWorfo_c")
        GMSPlacesClient.provideAPIKey("AIzaSyAeY00fzw5JsG3B55MRO1jcZ9d41LbTTzw")
        
        IQKeyboardManager.shared.enable = true

        
        return true
    }

}

