//
//  TabBarViewController.swift
//  PUP001
//
//  Created by chuottp on 25/04/2023.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.backgroundColor = UIColor.white
        self.tabBar.barTintColor = UIColor.white
        tabBar.layer.cornerRadius = 12.0
        tabBar.layer.masksToBounds = true
        tabBar.itemPositioning = .centered
        let myTabBarItem0 = (self.tabBar.items?[0])! as UITabBarItem;         myTabBarItem0.image = UIImage(named: "Home")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal);         myTabBarItem0.selectedImage = UIImage(named: "HomeClick")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem0.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        
        let myTabBarItem1 = (self.tabBar.items?[1])! as UITabBarItem;         myTabBarItem1.image = UIImage(named: "TVShow")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal);         myTabBarItem1.selectedImage = UIImage(named: "TVShowClick")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem1.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        
        let myTabBarItem2 = (self.tabBar.items?[2])! as UITabBarItem;         myTabBarItem2.image = UIImage(named: "Favorite")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal);         myTabBarItem2.selectedImage = UIImage(named: "FavoriteClick")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem2.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        
        let myTabBarItem3 = (self.tabBar.items?[3])! as UITabBarItem;         myTabBarItem3.image = UIImage(named: "Tracking")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal);         myTabBarItem3.selectedImage = UIImage(named: "TrackingClick")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem3.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        
        let myTabBarItem4 = (self.tabBar.items?[4])! as UITabBarItem;         myTabBarItem4.image = UIImage(named: "Setting")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal);         myTabBarItem4.selectedImage = UIImage(named: "SettingClick")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem4.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
    }
}
