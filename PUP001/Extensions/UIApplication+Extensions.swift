//
//  UIApplication+Extensions.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import Foundation
import UIKit

extension UIApplication {
    class func topStackViewController(viewController: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return topStackViewController(viewController: navigationController.visibleViewController)
        }
        if let tabBarController = viewController as? UINavigationController {
            return topStackViewController(viewController: tabBarController)
        }
        if let presented = viewController?.presentedViewController {
            return topStackViewController(viewController: presented)
        }
        return viewController
    }
}

