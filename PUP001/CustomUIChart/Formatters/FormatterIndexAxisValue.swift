//
//  IndexAxisValueFormatter.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

@objc(ChartIndexAxisValueFormatter)
open class FormatterIndexAxisValue: NSObject, FormatterAxisValue
{
    @objc public var values: [String] = [String]()

    public override init()
    {
        super.init()
        
    }
    
    @objc public init(values: [String])
    {
        super.init()
        
        self.values = values
    }
    
    @objc public static func with(values: [String]) -> FormatterIndexAxisValue?
    {
        return FormatterIndexAxisValue(values: values)
    }
    
    open func stringForValue(_ value: Double,
                             axis: AxisBaseBarChart?) -> String
    {
        let index = Int(value.rounded())
        guard values.indices.contains(index), index == Int(value) else { return "" }
        return values[index]
    }
}

