//
//  ChartDataEntry.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

open class DataEntryChart: DataEntryBaseOfChart, NSCopying
{

    @objc open var x = 0.0
    
    public required init()
    {
        super.init()
    }
    
    @objc public init(x: Double, y: Double)
    {
        super.init(y: y)
        self.x = x
    }
    
    @objc public convenience init(x: Double, y: Double, data: Any?)
    {
        self.init(x: x, y: y)
        self.data = data
    }
    
    @objc public convenience init(x: Double, y: Double, icon: NSUIImage?)
    {
        self.init(x: x, y: y)
        self.icon = icon
    }
    
    @objc public convenience init(x: Double, y: Double, icon: NSUIImage?, data: Any?)
    {
        self.init(x: x, y: y)
        self.icon = icon
        self.data = data
    }
        
    open override var description: String
    {
        return "ChartDataEntry, x: \(x), y \(y)"
    }
    
    open func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = type(of: self).init()
        
        copy.x = x
        copy.y = y
        copy.data = data
        
        return copy
    }
}

extension DataEntryChart {
    open override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? DataEntryChart else { return false }

        if self === object
        {
            return true
        }

        return y == object.y
            && x == object.x
    }
}
