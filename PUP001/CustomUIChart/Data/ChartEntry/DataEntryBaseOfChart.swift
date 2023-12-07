//
//  ChartDataEntryBase.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

open class DataEntryBaseOfChart: NSObject
{
    @objc open var y = 0.0
    
    @objc open var data: Any?
    
    @objc open var icon: NSUIImage?
    
    public override required init()
    {
        super.init()
    }
    
    @objc public init(y: Double)
    {
        super.init()
        
        self.y = y
    }
    
    @objc public convenience init(y: Double, data: Any?)
    {
        self.init(y: y)
        
        self.data = data
    }
    
    @objc public convenience init(y: Double, icon: NSUIImage?)
    {
        self.init(y: y)

        self.icon = icon
    }

    @objc public convenience init(y: Double, icon: NSUIImage?, data: Any?)
    {
        self.init(y: y)

        self.icon = icon
        self.data = data
    }
    
    open override var description: String
    {
        return "ChartDataEntryBase, y \(y)"
    }
}

extension DataEntryBaseOfChart {
    open override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? DataEntryBaseOfChart else { return false }

        if self === object
        {
            return true
        }

        return y == object.y
    }
}

