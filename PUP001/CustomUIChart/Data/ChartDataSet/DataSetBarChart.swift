//
//  BarChartDataSet.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

open class DataSetBarChart: ChartDataSetBarLineScatterCandleBubble, ProtocolBarChartDataSet
{
    private func initialize()
    {
        self.highlightColor = NSUIColor.black
        
        self.calcStackSize(entries: entries as! [DataEntryBarChart])
        self.calcEntryCountIncludingStacks(entries: entries as! [DataEntryBarChart])
    }
    
    public required init()
    {
        super.init()
        initialize()
    }
    
    public override init(entries: [DataEntryChart], label: String)
    {
        super.init(entries: entries, label: label)
        initialize()
    }

    private var _stackSize = 1
    
    private var _entryCountStacks = 0
    
    private func calcEntryCountIncludingStacks(entries: [DataEntryBarChart])
    {
        _entryCountStacks = entries.lazy
            .map(\.stackSize)
            .reduce(into: 0, +=)
    }
    
    private func calcStackSize(entries: [DataEntryBarChart])
    {
        _stackSize = entries.lazy
            .map(\.stackSize)
            .max() ?? 1
    }
    
    open override func calcMinMax(entry e: DataEntryChart)
    {
        guard let e = e as? DataEntryBarChart,
            !e.y.isNaN
            else { return }
        
        if e.yValues == nil
        {
            _yMin = Swift.min(e.y, _yMin)
            _yMax = Swift.max(e.y, _yMax)
        }
        else
        {
            _yMin = Swift.min(-e.negativeSum, _yMin)
            _yMax = Swift.max(e.positiveSum, _yMax)
        }

        calcMinMaxX(entry: e)
    }
    
    open var stackSize: Int
    {
        return _stackSize
    }
    
    open var isStacked: Bool
    {
        return _stackSize > 1
    }
    
    @objc open var entryCountStacks: Int
    {
        return _entryCountStacks
    }
    
    open var stackLabels: [String] = []
    
    open var barShadowColor = NSUIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0)

    open var barBorderWidth : CGFloat = 0.0

    open var barBorderColor = NSUIColor.black

    open var highlightAlpha = CGFloat(120.0 / 255.0)
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! DataSetBarChart
        copy._stackSize = _stackSize
        copy._entryCountStacks = _entryCountStacks
        copy.stackLabels = stackLabels

        copy.barShadowColor = barShadowColor
        copy.barBorderWidth = barBorderWidth
        copy.barBorderColor = barBorderColor
        copy.highlightAlpha = highlightAlpha
        return copy
    }
}

