//
//  AppDelegate.swift
//  PUP001
//
//  Created by chuottp on 25/04/2023.
//

import UIKit
import AdMobManager
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     //   InternetManager.shared.startMonitoring()
        Global.shared.checkSaveStartDate()
        GADMobileAds.sharedInstance().start(completionHandler: nil) // start ads
        Global.shared.setUpDateShowAds()
//        let splashScreen = UIStoryboard(name: "LaunchScreen", bundle: nil)
//        guard let initialViewController = splashScreen.instantiateInitialViewController() else { return false }
//        UIApplication.shared.windows.first?.rootViewController = initialViewController
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            guard let viewController = mainStoryboard.instantiateInitialViewController() else { return }
//            UIApplication.shared.windows.first?.rootViewController = viewController
//        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

