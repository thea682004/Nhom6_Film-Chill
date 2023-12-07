//
//  UIColor+Extensions.swift
//  PUP001
//
//  Created by chuottp on 10/05/2023.
//

import UIKit
import Foundation

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF, alpha: alpha
        )
    }
    
    func inversion() -> UIColor {
        guard let components = self.cgColor.components else {
            return .clear
        }
        
        var red: CGFloat = 0.0
        if components.count >= 1 {
            red = components[0]
        }
        
        var green: CGFloat = 0.0
        if components.count >= 2 {
            green = components[1]
        }
        
        var blue: CGFloat = 0.0
        if components.count >= 3 {
            blue = components[2]
        }
        
        var alpha: CGFloat = 0.0
        if components.count >= 3 {
            alpha = components[3]
        }
        return UIColor(red: 1 - red, green: 1 - green, blue: 1 - blue, alpha: alpha)
    }
}

