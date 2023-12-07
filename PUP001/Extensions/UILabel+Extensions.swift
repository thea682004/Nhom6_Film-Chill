//
//  UILabel+Extensions.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import Foundation
import UIKit

extension UILabel {
    //ghep chuoi va change color
    func customFont(textFirst: String, textEnd: String, fontFirst: UIFont, fontEnd: UIFont) {
        
        let numAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: fontFirst,
            
        ]
        let hoursAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: fontEnd
        ]
        let joinText = [textFirst, textEnd].joined(separator: " ")
        let attributedString = NSMutableAttributedString(string: joinText)
        let range2 = attributedString.mutableString.range(of: textFirst)
        let range3 = attributedString.mutableString.range(of: textEnd)
        
        attributedString.addAttributes(numAttributes, range: range2)
        attributedString.addAttributes(hoursAttributes, range: range3)
        
        self.attributedText = attributedString
    }
    
    func customLabel(textFirst: String, fontFirst: UIFont, textEnd: String, colorFirst: UIColor, fontEnd: UIFont, colorEnd: UIColor) {
        
        let numAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: fontFirst,
            NSAttributedString.Key.foregroundColor: colorFirst
        ]
        let hoursAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: fontEnd,
            NSAttributedString.Key.foregroundColor: colorEnd
        ]
        let joinText = [textFirst, textEnd].joined(separator: " ")
        let attributedString = NSMutableAttributedString(string: joinText)
        let range2 = attributedString.mutableString.range(of: textFirst)
        let range3 = attributedString.mutableString.range(of: textEnd)
        
        attributedString.addAttributes(numAttributes, range: range2)
        attributedString.addAttributes(hoursAttributes, range: range3)
        
        self.attributedText = attributedString
    }
}





