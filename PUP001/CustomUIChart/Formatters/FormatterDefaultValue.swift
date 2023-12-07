//
//  DefaultValueFormatter.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

@objc(ChartDefaultValueFormatter)
open class FormatterDefaultValue: NSObject, FormatterValue
{
    public typealias Block = (
        _ value: Double,
        _ entry: DataEntryChart,
        _ dataSetIndex: Int,
        _ viewPortHandler: ViewPortHandler?) -> String
    
    @objc open var block: Block?
    
    @objc open var hasAutoDecimals: Bool
    
    @objc open var formatter: NumberFormatter?
    {
        willSet
        {
            hasAutoDecimals = false
        }
    }
    
    open var decimals: Int?
    {
        didSet
        {
            setupDecimals(decimals: decimals)
        }
    }

    private func setupDecimals(decimals: Int?)
    {
        if let digits = decimals
        {
            formatter?.minimumFractionDigits = digits
            formatter?.maximumFractionDigits = digits
            formatter?.usesGroupingSeparator = true
        }
    }
    
    public override init()
    {
        formatter = NumberFormatter()
        formatter?.usesGroupingSeparator = true
        decimals = 1
        hasAutoDecimals = true

        super.init()
        setupDecimals(decimals: decimals)
    }
    
    @objc public init(formatter: NumberFormatter)
    {
        self.formatter = formatter
        hasAutoDecimals = false

        super.init()
    }
    
    @objc public init(decimals: Int)
    {
        formatter = NumberFormatter()
        formatter?.usesGroupingSeparator = true
        self.decimals = decimals
        hasAutoDecimals = true

        super.init()
        setupDecimals(decimals: decimals)
    }
    
    @objc public init(block: @escaping Block)
    {
        self.block = block
        hasAutoDecimals = false

        super.init()
    }

    @available(*, deprecated, message: "Use `init(block:)` instead.")
    @objc public static func with(block: @escaping Block) -> FormatterDefaultValue
    {
        return FormatterDefaultValue(block: block)
    }
    
    open func stringForValue(_ value: Double,
                             entry: DataEntryChart,
                             dataSetIndex: Int,
                             viewPortHandler: ViewPortHandler?) -> String
    {
        if let block = block {
            return block(value, entry, dataSetIndex, viewPortHandler)
        } else {
            return formatter?.string(from: NSNumber(floatLiteral: value)) ?? ""
        }
    }
}
