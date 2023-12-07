//
//  ViewPortJob.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc(ChartViewPortJob)
open class ViewPortJobBarChart: NSObject
{
    internal var point: CGPoint = .zero
    internal unowned var viewPortHandler: ViewPortHandler
    internal var xValue = 0.0
    internal var yValue = 0.0
    internal unowned var transformer: TransformerBarChart
    internal unowned var view: ChartViewBase

    @objc public init(
        viewPortHandler: ViewPortHandler,
        xValue: Double,
        yValue: Double,
        transformer: TransformerBarChart,
        view: ChartViewBase)
    {
        self.viewPortHandler = viewPortHandler
        self.xValue = xValue
        self.yValue = yValue
        self.transformer = transformer
        self.view = view

        super.init()
    }
    
    @objc open func doJob()
    {
        fatalError("`doJob()` must be overridden by subclasses")
    }
}

