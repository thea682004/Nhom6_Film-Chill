//
//  NSObject+Extensions.swift
//  Movie3Phu
//
//  Created by chuottp on 12/10/2023.
//

import Foundation

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return String(describing: self)
    }
}

