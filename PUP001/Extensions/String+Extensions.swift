//
//  String+Extensions.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import Foundation
import UIKit

extension String {
    func heightText(width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let text: String = self
        return text.boundingRect(with: maxSize,
                                 options: .usesLineFragmentOrigin,
                                 attributes: [.font: font],
                                 context: nil).height + 1
    }
    
    func widthText(height: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: CGFloat(MAXFLOAT), height: height)
        let text: String = self
        return text.boundingRect(with: maxSize,
                                 options: .usesLineFragmentOrigin,
                                 attributes: [.font: font],
                                 context: nil).width + 1
    }
    
    func asDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.date(from: self)
    }
    
    func asDateTime() -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: self)
    }
}
