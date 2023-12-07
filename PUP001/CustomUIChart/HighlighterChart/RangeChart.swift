//
//  Range.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

@objc(ChartRange)
open class RangeChart: NSObject
{
    @objc open var from: Double
    @objc open var to: Double
    
    @objc public init(from: Double, to: Double)
    {
        self.from = from
        self.to = to
        
        super.init()
    }

    @objc open func contains(_ value: Double) -> Bool
    {
        if value > from && value <= to
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    @objc open func isLarger(_ value: Double) -> Bool
    {
        return value > to
    }
    
    @objc open func isSmaller(_ value: Double) -> Bool
    {
        return value < from
    }
}

