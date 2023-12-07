//
//  Transformer.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics


@objc(ChartTransformer)
open class TransformerBarChart: NSObject
{
    internal var matrixValue = CGAffineTransform.identity
    
    internal var matrixOffset = CGAffineTransform.identity
    
    internal var viewPortHandler: ViewPortHandler
    
    @objc public init(viewPortHandler: ViewPortHandler)
    {
        self.viewPortHandler = viewPortHandler
    }
    
    @objc open func prepareMatrixValuePx(chartXMin: Double, deltaX: CGFloat, deltaY: CGFloat, chartYMin: Double)
    {
        var scaleX = (viewPortHandler.contentWidth / deltaX)
        var scaleY = (viewPortHandler.contentHeight / deltaY)
        
        if .infinity == scaleX
        {
            scaleX = 0.0
        }
        if .infinity == scaleY
        {
            scaleY = 0.0
        }
        
        matrixValue = CGAffineTransform.identity
            .scaledBy(x: scaleX, y: -scaleY)
            .translatedBy(x: CGFloat(-chartXMin), y: CGFloat(-chartYMin))
    }
    
    @objc open func prepareMatrixOffsetBarChart(inverted: Bool)
    {
        if !inverted
        {
            matrixOffset = CGAffineTransform(translationX: viewPortHandler.offsetLeft, y: viewPortHandler.chartHeight - viewPortHandler.offsetBottom)
        }
        else
        {
            matrixOffset = CGAffineTransform(scaleX: 1.0, y: -1.0)
                .translatedBy(x: viewPortHandler.offsetLeft, y: -viewPortHandler.offsetTop)
        }
    }
    
    open func pointValuesToPixelBarChart(_ points: inout [CGPoint])
    {
        let trans = valueToPixelMatrixBarChart
        points = points.map { $0.applying(trans) }
    }
    
    open func pointValueToPixelBarChart(_ point: inout CGPoint)
    {
        point = point.applying(valueToPixelMatrixBarChart)
    }
    
    @objc open func pixelForValuesBarChart(x: Double, y: Double) -> CGPoint
    {
        return CGPoint(x: x, y: y).applying(valueToPixelMatrixBarChart)
    }
    
    open func rectValueToPixelBarChart(_ r: inout CGRect)
    {
        r = r.applying(valueToPixelMatrixBarChart)
    }
    
    open func rectValueToPixelBarChart(_ r: inout CGRect, phaseY: Double)
    {
        var bottom = r.origin.y + r.size.height
        bottom *= CGFloat(phaseY)
        let top = r.origin.y * CGFloat(phaseY)
        r.size.height = bottom - top
        r.origin.y = top
        
        r = r.applying(valueToPixelMatrixBarChart)
    }
    
    open func rectValueToPixelHorizontalBarChart(_ r: inout CGRect)
    {
        r = r.applying(valueToPixelMatrixBarChart)
    }
    
    open func rectValueToPixelHorizontalBarChart(_ r: inout CGRect, phaseY: Double)
    {
        let left = r.origin.x * CGFloat(phaseY)
        let right = (r.origin.x + r.size.width) * CGFloat(phaseY)
        r.size.width = right - left
        r.origin.x = left
        
        r = r.applying(valueToPixelMatrixBarChart)
    }
    
    open func rectValuesToPixelBarChart(_ rects: inout [CGRect])
    {
        let trans = valueToPixelMatrixBarChart
        rects = rects.map { $0.applying(trans) }
    }
    
    open func pixelsToValuesBarChart(_ pixels: inout [CGPoint])
    {
        let trans = pixelToValueMatrixBarChart
        pixels = pixels.map { $0.applying(trans) }
    }
    
    open func pixelToValuesBarChart(_ pixel: inout CGPoint)
    {
        pixel = pixel.applying(pixelToValueMatrixBarChart)
    }
    
    @objc open func valueForTouchPointBarChart(_ point: CGPoint) -> CGPoint
    {
        return point.applying(pixelToValueMatrixBarChart)
    }
    
    @objc open func valueForTouchPointBarChart(x: CGFloat, y: CGFloat) -> CGPoint
    {
        return CGPoint(x: x, y: y).applying(pixelToValueMatrixBarChart)
    }
    
    @objc open var valueToPixelMatrixBarChart: CGAffineTransform
    {
        return
        matrixValue.concatenating(viewPortHandler.touchMatrix)
            .concatenating(matrixOffset
            )
    }
    
    @objc open var pixelToValueMatrixBarChart: CGAffineTransform
    {
        return valueToPixelMatrixBarChart.inverted()
    }
}

