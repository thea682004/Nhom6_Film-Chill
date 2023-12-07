//
//  YAxis.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(Cocoa)
import Cocoa
#endif

@objc(ChartYAxis)
open class YAxisChart: AxisBaseBarChart
{
    @objc(YAxisLabelPosition)
    public enum LabelPosition: Int
    {
        case outsideChart
        case insideChart
    }
    
    @objc
    public enum AxisDependency: Int
    {
        case left
        case right
    }
    @objc open var drawBottomYLabelEntryEnabled = true
    
    @objc open var drawTopYLabelEntryEnabled = true
    
    @objc open var inverted = false
    
    @objc open var drawZeroLineEnabled = false
    
    @objc open var zeroLineColor: NSUIColor? = NSUIColor.gray
    
    @objc open var zeroLineWidth: CGFloat = 1.0
    
    @objc open var zeroLineDashPhase = CGFloat(0.0)
    
    @objc open var zeroLineDashLengths: [CGFloat]?

    @objc open var spaceTop = CGFloat(0.1)

    @objc open var spaceBottom = CGFloat(0.1)
    
    @objc open var labelPosition = LabelPosition.outsideChart

    @objc open var labelAlignment: TextAlignment = .left

    @objc open var labelXOffset: CGFloat = 0.0
    
    private var _axisDependency = AxisDependency.left
    
    @objc open var minWidth = CGFloat(0)
    
    @objc open var maxWidth = CGFloat(CGFloat.infinity)
    
    public override init()
    {
        super.init()
        
        self.yOffset = 0.0
    }
    
    @objc public init(position: AxisDependency)
    {
        super.init()
        
        _axisDependency = position
        
        self.yOffset = 0.0
    }
    
    @objc open var axisDependency: AxisDependency
    {
        return _axisDependency
    }
    
    @objc open func requiredSize() -> CGSize
    {
        let label = getLongestLabel() as NSString
        var size = label.size(withAttributes: [.font: labelFont])
        size.width += xOffset * 2.0
        size.height += yOffset * 2.0
        size.width = max(minWidth, min(size.width, maxWidth > 0.0 ? maxWidth : size.width))
        return size
    }
    
    @objc open func getRequiredHeightSpace() -> CGFloat
    {
        return requiredSize().height
    }
    
    @objc open var needsOffset: Bool
    {
        if isEnabled && isDrawLabelsEnabled && labelPosition == .outsideChart
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    @objc open var isInverted: Bool { return inverted }
    
    open override func calculate(min dataMin: Double, max dataMax: Double)
    {
        var min = _customAxisMin ? _axisMinimum : dataMin
        var max = _customAxisMax ? _axisMaximum : dataMax
        if min > max
        {
            switch(_customAxisMax, _customAxisMin)
            {
            case(true, true):
                (min, max) = (max, min)
            case(true, false):
                min = max < 0 ? max * 1.5 : max * 0.5
            case(false, true):
                max = min < 0 ? min * 0.5 : min * 1.5
            case(false, false):
                break
            }
        }
        let range = abs(max - min)
      
        if range == 0.0
        {
            max = max + 1.0
            min = min - 1.0
        }
        
        if !_customAxisMin
        {
            let bottomSpace = range * Double(spaceBottom)
            _axisMinimum = (min - bottomSpace)
        }
        
        if !_customAxisMax
        {
            let topSpace = range * Double(spaceTop)
            _axisMaximum = (max + topSpace)
        }
        
        axisRange = abs(_axisMaximum - _axisMinimum)
    }
    
    @objc open var isDrawBottomYLabelEntryEnabled: Bool { return drawBottomYLabelEntryEnabled }
    
    @objc open var isDrawTopYLabelEntryEnabled: Bool { return drawTopYLabelEntryEnabled }

}

