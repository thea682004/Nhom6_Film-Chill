//
//  ArrayExtensions.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import Foundation

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension Array where Element: Equatable {
    func unique() -> [Element] {
        var uniqueArray = [Element]()
        for element in self {
            if !uniqueArray.contains(element) {
                uniqueArray.append(element)
            }
        }
        return uniqueArray
    }
}

