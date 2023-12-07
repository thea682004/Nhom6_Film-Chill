//
//  XAxis.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc(ChartXAxis)
open class XAxisChart: AxisBaseBarChart
{
    @objc(XAxisLabelPosition)
    public enum LabelPosition: Int
    {
        case top
        case bottom
        case bothSided
        case topInside
        case bottomInside
    }
    @objc open var labelWidth = CGFloat(1.0)
    
    @objc open var labelHeight = CGFloat(1.0)
    
    @objc open var labelRotatedWidth = CGFloat(1.0)
    
    @objc open var labelRotatedHeight = CGFloat(1.0)
    
    @objc open var labelRotationAngle = CGFloat(0.0)

    @objc open var avoidFirstLastClippingEnabled = false
    
    @objc open var labelPosition = LabelPosition.top
    
    @objc open var wordWrapEnabled = false
    
    @objc open var isWordWrapEnabled: Bool { return wordWrapEnabled }
    
    @objc open var wordWrapWidthPercent: CGFloat = 1.0
    
    public override init()
    {
        super.init()
        
        self.yOffset = 4.0
    }
    
    @objc open var isAvoidFirstLastClippingEnabled: Bool
    {
        return avoidFirstLastClippingEnabled
    }
}

