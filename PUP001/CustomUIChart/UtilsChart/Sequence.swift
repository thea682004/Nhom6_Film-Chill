//
//  Sequence.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation


extension Sequence {
    func max<T>(
        by key: KeyPath<Element, T>,
        areInIncreasingOrder: (T, T) -> Bool
    ) -> Element? {
        self.max { areInIncreasingOrder($0[keyPath: key], $1[keyPath: key]) }
    }
    
    func max<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Element? {
        max(by: keyPath, areInIncreasingOrder: <)
    }
}

