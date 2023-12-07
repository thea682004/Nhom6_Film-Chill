//
//  AxisBase.swift
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

@objc(ChartAxisBase)
open class AxisBaseBarChart: ComponentBaseChart
{
    public override init()
    {
        super.init()
    }
    
    private lazy var _axisValueFormatter: FormatterAxisValue = FormatterDefaultAxisValue(decimals: decimals)
    
    @objc open var labelFont = NSUIFont.systemFont(ofSize: 10.0)
    @objc open var labelTextColor = NSUIColor.labelOrBlack
    
    @objc open var axisLineColor = NSUIColor.gray
    @objc open var axisLineWidth = CGFloat(0.5)
    @objc open var axisLineDashPhase = CGFloat(0.0)
    @objc open var axisLineDashLengths: [CGFloat]!
    
    @objc open var gridColor = NSUIColor.gray.withAlphaComponent(0.9)
    @objc open var gridLineWidth = CGFloat(0.5)
    @objc open var gridLineDashPhase = CGFloat(0.0)
    @objc open var gridLineDashLengths: [CGFloat]!
    @objc open var gridLineCap = CGLineCap.butt
    @objc open var drawGridLinesEnabled = true
    @objc open var drawAxisLineEnabled = true
    @objc open var drawLabelsEnabled = true
    
    private var _centerAxisLabelsEnabled = false

    @objc open var centerAxisLabelsEnabled: Bool
    {
        get { return _centerAxisLabelsEnabled && entryCount > 0 }
        set { _centerAxisLabelsEnabled = newValue }
    }
    
    @objc open var isCenterAxisLabelsEnabled: Bool
    {
        get { return centerAxisLabelsEnabled }
    }

    private var _limitLines = [ChartLimitLineChart]()
    
    @objc open var drawLimitLinesBehindDataEnabled = false
    
    @objc open var drawGridLinesBehindDataEnabled = true

    @objc open var gridAntialiasEnabled = true
    
    @objc open var entries = [Double]()
    
    @objc open var centeredEntries = [Double]()
    
    @objc open var entryCount: Int { return entries.count }
    
    private var _labelCount = Int(6)
    
    @objc open var decimals: Int = 0
    
    @objc open var granularityEnabled = false
    
    private var _granularity = Double(1.0)
    
    @objc open var granularity: Double
    {
        get
        {
            return _granularity
        }
        set
        {
            _granularity = newValue
            granularityEnabled = true
        }
    }
    
    @objc open var isGranularityEnabled: Bool
    {
        get
        {
            return granularityEnabled
        }
    }
    
    @objc open var forceLabelsEnabled = false
    
    @objc open func getLongestLabel() -> String
    {
        let longest = entries.indices
            .lazy
            .map(getFormattedLabel(_:))
            .max(by: \.count)

        return longest ?? ""
    }
    
    @objc open func getFormattedLabel(_ index: Int) -> String
    {
        guard entries.indices.contains(index) else { return "" }
        
        return valueFormatter?.stringForValue(entries[index], axis: self) ?? ""
    }
    
    @objc open var valueFormatter: FormatterAxisValue?
    {
        get
        {
            if _axisValueFormatter is FormatterDefaultAxisValue &&
            (_axisValueFormatter as! FormatterDefaultAxisValue).hasAutoDecimals &&
                (_axisValueFormatter as! FormatterDefaultAxisValue).decimals != decimals
            {
                (self._axisValueFormatter as! FormatterDefaultAxisValue).decimals = self.decimals
            }

            return _axisValueFormatter
        }
        set
        {
            _axisValueFormatter = newValue ?? FormatterDefaultAxisValue(decimals: decimals)
        }
    }
    
    @objc open var isDrawGridLinesEnabled: Bool { return drawGridLinesEnabled }
    
    @objc open var isDrawAxisLineEnabled: Bool { return drawAxisLineEnabled }
    
    @objc open var isDrawLabelsEnabled: Bool { return drawLabelsEnabled }
    
    @objc open var isDrawLimitLinesBehindDataEnabled: Bool { return drawLimitLinesBehindDataEnabled }
    
    @objc open var isDrawGridLinesBehindDataEnabled: Bool { return drawGridLinesBehindDataEnabled }
    
    @objc open var spaceMin: Double = 0.0
    
    @objc open var spaceMax: Double = 0.0
    
    internal var _customAxisMin: Bool = false
    
    internal var _customAxisMax: Bool = false
    
    internal var _axisMinimum = Double(0)
    
    internal var _axisMaximum = Double(0)
    
    @objc open var axisRange = Double(0)
    
    @objc open var axisMinLabels = Int(2) {
        didSet { axisMinLabels = axisMinLabels > 0 ? axisMinLabels : oldValue }
    }
    
    @objc open var axisMaxLabels = Int(25) {
        didSet { axisMaxLabels = axisMaxLabels > 0 ? axisMaxLabels : oldValue }
    }
    
    @objc open var labelCount: Int
    {
        get
        {
            return _labelCount
        }
        set
        {
            let range = axisMinLabels...axisMaxLabels as ClosedRange
            _labelCount = newValue.clamped(to: range)
                        
            forceLabelsEnabled = false
        }
    }
    
    @objc open func setLabelCount(_ count: Int, force: Bool)
    {
        self.labelCount = count
        forceLabelsEnabled = force
    }
    
    @objc open var isForceLabelsEnabled: Bool { return forceLabelsEnabled }
    
    @objc open func addLimitLine(_ line: ChartLimitLineChart)
    {
        _limitLines.append(line)
    }
    
    @objc open func removeLimitLine(_ line: ChartLimitLineChart)
    {
        guard let i = _limitLines.firstIndex(of: line) else { return }
        _limitLines.remove(at: i)
    }
    
    @objc open func removeAllLimitLines()
    {
        _limitLines.removeAll(keepingCapacity: false)
    }
    
    @objc open var limitLines : [ChartLimitLineChart]
    {
        return _limitLines
    }
    
    @objc open func resetCustomAxisMin()
    {
        _customAxisMin = false
    }
    
    @objc open var isAxisMinCustom: Bool { return _customAxisMin }
    
    @objc open func resetCustomAxisMax()
    {
        _customAxisMax = false
    }
    
    @objc open var isAxisMaxCustom: Bool { return _customAxisMax }
        
    @objc open var axisMinimum: Double
    {
        get
        {
            return _axisMinimum
        }
        set
        {
            _customAxisMin = true
            _axisMinimum = newValue
            axisRange = abs(_axisMaximum - newValue)
        }
    }
    
    @objc open var axisMaximum: Double
    {
        get
        {
            return _axisMaximum
        }
        set
        {
            _customAxisMax = true
            _axisMaximum = newValue
            axisRange = abs(newValue - _axisMinimum)
        }
    }
    
    @objc open func calculate(min dataMin: Double, max dataMax: Double)
    {
        var min = _customAxisMin ? _axisMinimum : (dataMin - spaceMin)
        var max = _customAxisMax ? _axisMaximum : (dataMax + spaceMax)
        
        let range = abs(max - min)
        
        if range == 0.0
        {
            max = max + 1.0
            min = min - 1.0
        }
        
        _axisMinimum = min
        _axisMaximum = max
        axisRange = abs(max - min)
    }
}
