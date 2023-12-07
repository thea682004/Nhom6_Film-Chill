//
//  StringUltis.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import Foundation
class StringUtils {
    
    static let shared = StringUtils()
    
    static func toString(_ value: Any?) -> String {
        return String(describing: value ?? "")
    }
    
    func convertMonthToText(value: Int) -> String {
        switch value {
        case 1:
            return "January"
        case 2:
            return "February"
        case 3:
            return "March"
        case 4:
            return "April"
        case 5:
            return "May"
        case 6:
            return "June"
        case 7:
            return "July"
        case 8:
            return "August"
        case 9:
            return "September"
        case 10:
            return "Octorber"
        case 11:
            return "November"
        default:
            return "December"
        }
    }
}


