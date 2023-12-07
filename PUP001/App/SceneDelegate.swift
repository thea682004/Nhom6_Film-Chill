//
//  SceneDelegate.swift
//  PUP001
//
//  Created by chuottp on 25/04/2023.
//

import UIKit
import AdMobManager

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
//            window?.makeKeyAndVisible()
//
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
//                self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
//            }
            guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if Global.shared.isStateShowAds == true {
            if AdMobManager.shared.isReady(key: AppText.nameAds.open) ?? false {
                AdMobManager.shared.show(key: AppText.nameAds.open)
            }
        } else {
            print("Not show")
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

