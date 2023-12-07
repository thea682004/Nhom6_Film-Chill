//
//  UIView.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import Foundation
import UIKit

extension UIView {
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    @objc func push(to viewController: UIViewController, animated: Bool) {
        guard let topViewController = UIApplication.topStackViewController() else {
            return
        }
        topViewController.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    @objc func pop(animated: Bool) {
        guard let topViewController = UIApplication.topStackViewController() else {
            return
        }
        topViewController.navigationController?.popViewController(animated: animated)
    }
    
    @objc func present(to viewController: UIViewController, animated: Bool) {
        guard let topViewController = UIApplication.topStackViewController() else {
            return
        }
        topViewController.present(viewController, animated: animated, completion: nil)
    }
    
    class func initFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?[0] as! T
    }
    
    class func initView<T: UIView>(frame: CGRect) -> T {
        let view: T = initFromNib()
        view.frame = frame
        return view
    }
}
