//
//  AnimatedZoomViewJob.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

open class AnimatedZoomViewJobBarChart: AnimatedViewPortJobBarChart
{
    internal var yAxis: YAxisChart
    internal var xAxisRange: Double = 0.0
    internal var scaleX: CGFloat = 0.0
    internal var scaleY: CGFloat = 0.0
    internal var zoomOriginX: CGFloat = 0.0
    internal var zoomOriginY: CGFloat = 0.0
    internal var zoomCenterX: CGFloat = 0.0
    internal var zoomCenterY: CGFloat = 0.0

    @objc public init(
        viewPortHandler: ViewPortHandler,
        transformer: TransformerBarChart,
        view: ChartViewBase,
        yAxis: YAxisChart,
        xAxisRange: Double,
        scaleX: CGFloat,
        scaleY: CGFloat,
        xOrigin: CGFloat,
        yOrigin: CGFloat,
        zoomCenterX: CGFloat,
        zoomCenterY: CGFloat,
        zoomOriginX: CGFloat,
        zoomOriginY: CGFloat,
        duration: TimeInterval,
        easing: ChartEasingFunctionBlock?)
    {
        self.yAxis = yAxis
        self.xAxisRange = xAxisRange
        self.scaleX = scaleX
        self.scaleY = scaleY
        self.zoomCenterX = zoomCenterX
        self.zoomCenterY = zoomCenterY
        self.zoomOriginX = zoomOriginX
        self.zoomOriginY = zoomOriginY

        super.init(viewPortHandler: viewPortHandler,
            xValue: 0.0,
            yValue: 0.0,
            transformer: transformer,
            view: view,
            xOrigin: xOrigin,
            yOrigin: yOrigin,
            duration: duration,
            easing: easing)
    }
    
    internal override func animationUpdate()
    {
        let scaleX = xOrigin + (self.scaleX - xOrigin) * phase
        let scaleY = yOrigin + (self.scaleY - yOrigin) * phase
        
        var matrix = viewPortHandler.setZoom(scaleX: scaleX, scaleY: scaleY)
        viewPortHandler.refresh(newMatrix: matrix, chart: view, invalidate: false)
        
        let valsInView = CGFloat(yAxis.axisRange) / viewPortHandler.scaleY
        let xsInView = CGFloat(xAxisRange) / viewPortHandler.scaleX
        
        var pt = CGPoint(
            x: zoomOriginX + ((zoomCenterX - xsInView / 2.0) - zoomOriginX) * phase,
            y: zoomOriginY + ((zoomCenterY + valsInView / 2.0) - zoomOriginY) * phase
        )
        
        transformer.pointValueToPixelBarChart(&pt)
        
        matrix = viewPortHandler.translate(pt: pt)
        viewPortHandler.refresh(newMatrix: matrix, chart: view, invalidate: true)
    }
    
    internal override func animationEnd()
    {
        (view as? BarLineChartViewBase)?.calculateOffsets()
        view.setNeedsDisplay()
    }
}

