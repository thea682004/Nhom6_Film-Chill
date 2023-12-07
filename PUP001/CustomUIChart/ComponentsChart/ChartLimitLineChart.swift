//
//  ChartLimitLine.swift
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

open class ChartLimitLineChart: ComponentBaseChart
{
    @objc(ChartLimitLabelPosition)
    public enum LabelPosition: Int
    {
        case leftTop
        case leftBottom
        case rightTop
        case rightBottom
    }
    
    @objc open var limit = Double(0.0)
    
    private var _lineWidth = CGFloat(2.0)
    @objc open var lineColor = NSUIColor(red: 237.0/255.0, green: 91.0/255.0, blue: 91.0/255.0, alpha: 1.0)
    @objc open var lineDashPhase = CGFloat(0.0)
    @objc open var lineDashLengths: [CGFloat]?
    
    @objc open var valueTextColor = NSUIColor.labelOrBlack
    @objc open var valueFont = NSUIFont.systemFont(ofSize: 13.0)
    
    @objc open var drawLabelEnabled = true
    @objc open var label = ""
    @objc open var labelPosition = LabelPosition.rightTop
    
    public override init()
    {
        super.init()
    }
    
    @objc public init(limit: Double)
    {
        super.init()
        self.limit = limit
    }
    
    @objc public init(limit: Double, label: String)
    {
        super.init()
        self.limit = limit
        self.label = label
    }
    
    @objc open var lineWidth: CGFloat
    {
        get
        {
            return _lineWidth
        }
        set
        {
            _lineWidth = newValue.clamped(to: 0.2...12)
        }
    }
}

