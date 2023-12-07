//
//  AppFont.swift
//  ChatGPT_MinhTX
//
//  Created by chuottp on 12/10/2023.
//

import UIKit

class AppFont {
    enum FontName: String {
        case interMedium = "Inter-Medium"
        case interRegular = "Iter-Regular"
        case poppinSemobold = "Poppins-Semibold"
        case poppinRegular = "Poppins-Regular"
        case poppinsMedium = "Popins-Medium"
    }
    
    class func getFont(fontName: FontName, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: fontName.rawValue, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
}
