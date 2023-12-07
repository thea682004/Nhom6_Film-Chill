//
//  DefaultAxisValueFormatter.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

@objc(ChartDefaultAxisValueFormatter)
open class FormatterDefaultAxisValue: NSObject, FormatterAxisValue
{
    public typealias Block = (
        _ value: Double,
        _ axis: AxisBaseBarChart?) -> String
    
    @objc open var block: Block?
    
    @objc open var hasAutoDecimals: Bool = false
    
    private var _formatter: NumberFormatter?
    @objc open var formatter: NumberFormatter?
    {
        get { return _formatter }
        set
        {
            hasAutoDecimals = false
            _formatter = newValue
        }
    }

    private var _decimals: Int?
    open var decimals: Int?
    {
        get { return _decimals }
        set
        {
            _decimals = newValue
            
            if let digits = newValue
            {
                self.formatter?.minimumFractionDigits = digits
                self.formatter?.maximumFractionDigits = digits
                self.formatter?.usesGroupingSeparator = true
            }
        }
    }
    
    public override init()
    {
        super.init()
        
        self.formatter = NumberFormatter()
        hasAutoDecimals = true
    }
    
    @objc public init(formatter: NumberFormatter)
    {
        super.init()
        
        self.formatter = formatter
    }
    
    @objc public init(decimals: Int)
    {
        super.init()
        
        self.formatter = NumberFormatter()
        self.formatter?.usesGroupingSeparator = true
        self.decimals = decimals
        hasAutoDecimals = true
    }
    
    @objc public init(block: @escaping Block)
    {
        super.init()
        
        self.block = block
    }
    
    @objc public static func with(block: @escaping Block) -> FormatterDefaultAxisValue?
    {
        return FormatterDefaultAxisValue(block: block)
    }
    
    open func stringForValue(_ value: Double,
                               axis: AxisBaseBarChart?) -> String
    {
        if let block = block {
            return block(value, axis)
        } else {
            return formatter?.string(from: NSNumber(floatLiteral: value)) ?? ""
        }
    }
}

