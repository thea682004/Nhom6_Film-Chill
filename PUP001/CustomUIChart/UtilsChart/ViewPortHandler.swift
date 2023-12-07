//
//  ViewPortHandler.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc(ChartViewPortHandler)
open class ViewPortHandler: NSObject
{
    @objc open private(set) var touchMatrix = CGAffineTransform.identity
    @objc open private(set) var contentRect = CGRect()
    @objc open private(set) var chartWidth: CGFloat = 0
    @objc open private(set) var chartHeight: CGFloat = 0
    @objc open private(set) var minScaleY: CGFloat = 1.0
    @objc open private(set) var maxScaleY = CGFloat.greatestFiniteMagnitude
    @objc open private(set) var minScaleX: CGFloat = 1.0
    @objc open private(set) var maxScaleX = CGFloat.greatestFiniteMagnitude
    @objc open private(set) var scaleX: CGFloat = 1.0
    @objc open private(set) var scaleY: CGFloat = 1.0
    @objc open private(set) var transX: CGFloat = 0
    @objc open private(set) var transY: CGFloat = 0
    private var transOffsetX: CGFloat = 0
    private var transOffsetY: CGFloat = 0
    @objc public init(width: CGFloat, height: CGFloat)
    {
        super.init()
        
        setChartDimens(width: width, height: height)
    }
    
    @objc open func setChartDimens(width: CGFloat, height: CGFloat)
    {
        let offsetLeft = self.offsetLeft
        let offsetTop = self.offsetTop
        let offsetRight = self.offsetRight
        let offsetBottom = self.offsetBottom
        
        chartHeight = height
        chartWidth = width
        
        restrainViewPort(offsetLeft: offsetLeft, offsetTop: offsetTop, offsetRight: offsetRight, offsetBottom: offsetBottom)
    }
    
    @objc open var hasChartDimens: Bool
    {
        return chartHeight > 0.0
        && chartWidth > 0.0
    }
    
    @objc open func restrainViewPort(offsetLeft: CGFloat, offsetTop: CGFloat, offsetRight: CGFloat, offsetBottom: CGFloat)
    {
        contentRect.origin.x = offsetLeft
        contentRect.origin.y = offsetTop
        contentRect.size.width = chartWidth - offsetLeft - offsetRight
        contentRect.size.height = chartHeight - offsetBottom - offsetTop
    }
    
    @objc open var offsetLeft: CGFloat
    {
        return contentRect.origin.x
    }
    
    @objc open var offsetRight: CGFloat
    {
        return chartWidth - contentRect.size.width - contentRect.origin.x
    }
    
    @objc open var offsetTop: CGFloat
    {
        return contentRect.origin.y
    }
    
    @objc open var offsetBottom: CGFloat
    {
        return chartHeight - contentRect.size.height - contentRect.origin.y
    }
    
    @objc open var contentTop: CGFloat
    {
        return contentRect.origin.y
    }
    
    @objc open var contentLeft: CGFloat
    {
        return contentRect.origin.x
    }
    
    @objc open var contentRight: CGFloat
    {
        return contentRect.origin.x + contentRect.size.width
    }
    
    @objc open var contentBottom: CGFloat
    {
        return contentRect.origin.y + contentRect.size.height
    }
    
    @objc open var contentWidth: CGFloat
    {
        return contentRect.size.width
    }
    
    @objc open var contentHeight: CGFloat
    {
        return contentRect.size.height
    }
    
    @objc open var contentCenter: CGPoint
    {
        return CGPoint(x: contentRect.origin.x + contentRect.size.width / 2.0, y: contentRect.origin.y + contentRect.size.height / 2.0)
    }
    
    @objc open func zoom(scaleX: CGFloat, scaleY: CGFloat) -> CGAffineTransform
    {
        return touchMatrix.scaledBy(x: scaleX, y: scaleY)
    }
    
    @objc open func zoom(scaleX: CGFloat, scaleY: CGFloat, x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        return touchMatrix.translatedBy(x: x, y: y)
            .scaledBy(x: scaleX, y: scaleY)
            .translatedBy(x: -x, y: -y)
    }
    
    @objc open func zoomIn(x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        return zoom(scaleX: 1.4, scaleY: 1.4, x: x, y: y)
    }
    
    @objc open func zoomOut(x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        return zoom(scaleX: 0.7, scaleY: 0.7, x: x, y: y)
    }
    
    @objc open func resetZoom() -> CGAffineTransform
    {
        return zoom(scaleX: 1.0, scaleY: 1.0, x: 0.0, y: 0.0)
    }
    
    @objc open func setZoom(scaleX: CGFloat, scaleY: CGFloat) -> CGAffineTransform
    {
        var matrix = touchMatrix
        matrix.a = scaleX
        matrix.d = scaleY
        return matrix
    }
    
    @objc open func setZoom(scaleX: CGFloat, scaleY: CGFloat, x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        var matrix = touchMatrix
        matrix.a = 1.0
        matrix.d = 1.0
        matrix = matrix.translatedBy(x: x, y: y)
            .scaledBy(x: scaleX, y: scaleY)
            .translatedBy(x: -x, y: -y)
        return matrix
    }
    
    @objc open func fitScreen() -> CGAffineTransform
    {
        minScaleX = 1.0
        minScaleY = 1.0
        
        return .identity
    }
    
    @objc open func translate(pt: CGPoint) -> CGAffineTransform
    {
        let translateX = pt.x - offsetLeft
        let translateY = pt.y - offsetTop
        
        let matrix = touchMatrix.concatenating(CGAffineTransform(translationX: -translateX, y: -translateY))
        
        return matrix
    }
    
    @objc open func centerViewPort(pt: CGPoint, chart: ChartViewBase)
    {
        let translateX = pt.x - offsetLeft
        let translateY = pt.y - offsetTop
        
        let matrix = touchMatrix.concatenating(CGAffineTransform(translationX: -translateX, y: -translateY))
        refresh(newMatrix: matrix, chart: chart, invalidate: true)
    }
    
    @objc @discardableResult open func refresh(newMatrix: CGAffineTransform, chart: ChartViewBase, invalidate: Bool) -> CGAffineTransform
    {
        touchMatrix = newMatrix
        
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
        
        chart.setNeedsDisplay()
        
        return touchMatrix
    }
    
    private func limitTransAndScale(matrix: inout CGAffineTransform, content: CGRect)
    {
        scaleX = min(max(minScaleX, matrix.a), maxScaleX)
        
        scaleY = min(max(minScaleY,  matrix.d), maxScaleY)
        
        let width = content.width
        let height = content.height
        
        let maxTransX = -width * (scaleX - 1.0)
        transX = min(max(matrix.tx, maxTransX - transOffsetX), transOffsetX)
        
        let maxTransY = height * (scaleY - 1.0)
        transY = max(min(matrix.ty, maxTransY + transOffsetY), -transOffsetY)
        
        matrix.tx = transX
        matrix.a = scaleX
        matrix.ty = transY
        matrix.d = scaleY
    }
    
    @objc open func setMinimumScaleX(_ xScale: CGFloat)
    {
        minScaleX = max(xScale, 1)
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    @objc open func setMaximumScaleX(_ xScale: CGFloat)
    {
        maxScaleX = xScale == 0 ? .greatestFiniteMagnitude : xScale
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    @objc open func setMinMaxScaleX(minScaleX: CGFloat, maxScaleX: CGFloat)
    {
        self.minScaleX = max(minScaleX, 1)
        self.maxScaleX = maxScaleX == 0 ? .greatestFiniteMagnitude : maxScaleX
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    @objc open func setMinimumScaleY(_ yScale: CGFloat)
    {
        minScaleY = max(yScale, 1)
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    @objc open func setMaximumScaleY(_ yScale: CGFloat)
    {
        maxScaleY = yScale == 0 ? .greatestFiniteMagnitude : yScale
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    @objc open func setMinMaxScaleY(minScaleY: CGFloat, maxScaleY: CGFloat)
    {
        
        self.minScaleY = max(minScaleY, 1)
        self.maxScaleY = maxScaleY == 0 ? .greatestFiniteMagnitude : maxScaleY
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    @objc open func isInBoundsX(_ x: CGFloat) -> Bool
    {
        return isInBoundsLeft(x) && isInBoundsRight(x)
    }
    
    @objc open func isInBoundsY(_ y: CGFloat) -> Bool
    {
        return isInBoundsTop(y) && isInBoundsBottom(y)
    }
    
    @objc open func isInBounds(point: CGPoint) -> Bool
    {
        return isInBounds(x: point.x, y: point.y)
    }
    
    @objc open func isInBounds(x: CGFloat, y: CGFloat) -> Bool
    {
        return isInBoundsX(x) && isInBoundsY(y)
    }
    
    @objc open func isInBoundsLeft(_ x: CGFloat) -> Bool
    {
        return contentRect.origin.x <= x + 1.0
    }
    
    @objc open func isInBoundsRight(_ x: CGFloat) -> Bool
    {
        let x = floor(x * 100.0) / 100.0
        return (contentRect.origin.x + contentRect.size.width) >= x - 1.0
    }
    
    @objc open func isInBoundsTop(_ y: CGFloat) -> Bool
    {
        return contentRect.origin.y <= y
    }
    
    @objc open func isInBoundsBottom(_ y: CGFloat) -> Bool
    {
        let normalizedY = floor(y * 100.0) / 100.0
        return (contentRect.origin.y + contentRect.size.height) >= normalizedY
    }
    
    @objc open func isIntersectingLine(from startPoint: CGPoint, to endPoint: CGPoint) -> Bool
    {
        if isInBounds(point: startPoint) || isInBounds(point: endPoint) { return true }
        if startPoint.x == endPoint.x { return isInBoundsX(startPoint.x) }
        
        let a = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x)
        let b = startPoint.y - (a * startPoint.x)
        if isInBoundsY((a * contentRect.minX) + b) { return true }
        guard a != 0 else { return false }
        if isInBoundsX((contentRect.maxY - b) / a) { return true }
        
        if isInBoundsX((contentRect.minY - b) / a) { return true }
        return false
    }
    
    @objc open var isFullyZoomedOut: Bool
    {
        return isFullyZoomedOutX && isFullyZoomedOutY
    }
    
    @objc open var isFullyZoomedOutY: Bool
    {
        return !(scaleY > minScaleY || minScaleY > 1.0)
    }
    
    @objc open var isFullyZoomedOutX: Bool
    {
        return !(scaleX > minScaleX || minScaleX > 1.0)
    }
    
    @objc open func setDragOffsetX(_ offset: CGFloat)
    {
        transOffsetX = offset
    }
    
    @objc open func setDragOffsetY(_ offset: CGFloat)
    {
        transOffsetY = offset
    }
    
    @objc open var hasNoDragOffset: Bool
    {
        return transOffsetX <= 0.0 && transOffsetY <= 0.0
    }
    
    @objc open var canZoomOutMoreX: Bool
    {
        return scaleX > minScaleX
    }
    
    @objc open var canZoomInMoreX: Bool
    {
        return scaleX < maxScaleX
    }
    
    @objc open var canZoomOutMoreY: Bool
    {
        return scaleY > minScaleY
    }
    
    @objc open var canZoomInMoreY: Bool
    {
        return scaleY < maxScaleY
    }
}

