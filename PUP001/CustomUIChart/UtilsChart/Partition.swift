//
//  Partition.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
extension Collection {
    func partitionIndex(
        where secondPartition: (Element) throws -> Bool
    ) rethrows -> Index {
        var n = count
        var l = startIndex
        
        while n > 0 {
            let half = n / 2
            let mid = index(l, offsetBy: half)
            if try secondPartition(self[mid]) {
                n = half
            } else {
                l = index(after: mid)
                n -= half + 1
            }
        }
        return l
    }
}

