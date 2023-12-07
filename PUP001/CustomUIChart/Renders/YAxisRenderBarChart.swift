//
//  YAxisRenderer.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics


@objc(ChartYAxisRenderer)
open class YAxisRenderBarChart: NSObject, AxisRenderBarChart
{
    @objc public let viewPortHandler: ViewPortHandler
    @objc public let axis: YAxisChart
    @objc public let transformer: TransformerBarChart?
    
    @objc public init(viewPortHandler: ViewPortHandler, axis: YAxisChart, transformer: TransformerBarChart?)
    {
        self.viewPortHandler = viewPortHandler
        self.axis = axis
        self.transformer = transformer
        
        super.init()
    }
    
    open func renderAxisLabels(context: CGContext)
    {
        guard
            axis.isEnabled,
            axis.isDrawLabelsEnabled
        else { return }
        
        let xoffset = axis.xOffset
        let yoffset = axis.labelFont.lineHeight / 2.5 + axis.yOffset
        
        let dependency = axis.axisDependency
        let labelPosition = axis.labelPosition
        
        let xPos: CGFloat
        let textAlign: TextAlignment
        
        if dependency == .left
        {
            if labelPosition == .outsideChart
            {
                textAlign = .right
                xPos = viewPortHandler.offsetLeft - xoffset
            }
            else
            {
                textAlign = .left
                xPos = viewPortHandler.offsetLeft + xoffset
            }
        }
        else
        {
            if labelPosition == .outsideChart
            {
                textAlign = .left
                xPos = viewPortHandler.contentRight + xoffset
            }
            else
            {
                textAlign = .right
                xPos = viewPortHandler.contentRight - xoffset
            }
        }
        
        drawYLabels(context: context,
                    fixedPosition: xPos,
                    positions: transformedPositions(),
                    offset: yoffset - axis.labelFont.lineHeight,
                    textAlign: textAlign)
    }
    
    open func renderAxisLine(context: CGContext)
    {
        guard
            axis.isEnabled,
            axis.drawAxisLineEnabled
        else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        context.setStrokeColor(axis.axisLineColor.cgColor)
        context.setLineWidth(axis.axisLineWidth)
        if axis.axisLineDashLengths != nil
        {
            context.setLineDash(phase: axis.axisLineDashPhase, lengths: axis.axisLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        if axis.axisDependency == .left
        {
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
            context.strokePath()
        }
        else
        {
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentBottom))
            context.strokePath()
        }
    }
    
    open func drawYLabels(
        context: CGContext,
        fixedPosition: CGFloat,
        positions: [CGPoint],
        offset: CGFloat,
        textAlign: TextAlignment)
    {
        let labelFont = axis.labelFont
        let labelTextColor = axis.labelTextColor
        
        let from = axis.isDrawBottomYLabelEntryEnabled ? 0 : 1
        let to = axis.isDrawTopYLabelEntryEnabled ? axis.entryCount : (axis.entryCount - 1)
        
        let xOffset = axis.labelXOffset
        
        for i in from..<to
        {
            let text = axis.getFormattedLabel(i)
            context.drawText(text,
                             at: CGPoint(x: fixedPosition + xOffset, y: positions[i].y + offset),
                             align: textAlign,
                             attributes: [.font: labelFont, .foregroundColor: labelTextColor])
        }
    }
    
    open func renderGridLines(context: CGContext)
    {
        guard axis.isEnabled else { return }
        
        if axis.drawGridLinesEnabled
        {
            let positions = transformedPositions()
            
            context.saveGState()
            defer { context.restoreGState() }
            context.clip(to: self.gridClippingRect)
            
            context.setShouldAntialias(axis.gridAntialiasEnabled)
            context.setStrokeColor(axis.gridColor.cgColor)
            context.setLineWidth(axis.gridLineWidth)
            context.setLineCap(axis.gridLineCap)
            
            if axis.gridLineDashLengths != nil
            {
                context.setLineDash(phase: axis.gridLineDashPhase, lengths: axis.gridLineDashLengths)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            positions.forEach { drawGridLine(context: context, position: $0) }
        }
        
        if axis.drawZeroLineEnabled
        {
            drawZeroLine(context: context)
        }
    }
    
    @objc open var gridClippingRect: CGRect
    {
        var contentRect = viewPortHandler.contentRect
        let dy = self.axis.gridLineWidth
        contentRect.origin.y -= dy / 2.0
        contentRect.size.height += dy
        return contentRect
    }
    
    @objc open func drawGridLine(
        context: CGContext,
        position: CGPoint)
    {
        context.beginPath()
        context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: position.y))
        context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: position.y))
        context.strokePath()
    }
    
    @objc open func transformedPositions() -> [CGPoint]
    {
        guard let transformer = self.transformer else { return [] }
        
        var positions = axis.entries.map { CGPoint(x: 0.0, y: $0) }
        transformer.pointValuesToPixelBarChart(&positions)
        
        return positions
    }
    
    @objc open func drawZeroLine(context: CGContext)
    {
        guard
            let transformer = self.transformer,
            let zeroLineColor = axis.zeroLineColor
        else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        var clippingRect = viewPortHandler.contentRect
        clippingRect.origin.y -= axis.zeroLineWidth / 2.0
        clippingRect.size.height += axis.zeroLineWidth
        context.clip(to: clippingRect)
        
        context.setStrokeColor(zeroLineColor.cgColor)
        context.setLineWidth(axis.zeroLineWidth)
        
        let pos = transformer.pixelForValuesBarChart(x: 0.0, y: 0.0)
        
        if axis.zeroLineDashLengths != nil
        {
            context.setLineDash(phase: axis.zeroLineDashPhase, lengths: axis.zeroLineDashLengths!)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: pos.y))
        context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: pos.y))
        context.drawPath(using: CGPathDrawingMode.stroke)
    }
    
    open func renderLimitLines(context: CGContext)
    {
        guard let transformer = self.transformer else { return }
        
        let limitLines = axis.limitLines
        
        guard !limitLines.isEmpty else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        let trans = transformer.valueToPixelMatrixBarChart
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for l in limitLines where l.isEnabled
        {
            context.saveGState()
            defer { context.restoreGState() }
            
            var clippingRect = viewPortHandler.contentRect
            clippingRect.origin.y -= l.lineWidth / 2.0
            clippingRect.size.height += l.lineWidth
            context.clip(to: clippingRect)
            
            position.x = 0.0
            position.y = CGFloat(l.limit)
            position = position.applying(trans)
            
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: position.y))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: position.y))
            
            context.setStrokeColor(l.lineColor.cgColor)
            context.setLineWidth(l.lineWidth)
            if l.lineDashLengths != nil
            {
                context.setLineDash(phase: l.lineDashPhase, lengths: l.lineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            context.strokePath()
            
            let label = l.label
            
            guard l.drawLabelEnabled, !label.isEmpty else { continue }
            
            let labelLineHeight = l.valueFont.lineHeight
            
            let xOffset = 4.0 + l.xOffset
            let yOffset = l.lineWidth + labelLineHeight + l.yOffset
            
            let align: TextAlignment
            let point: CGPoint
            
            switch l.labelPosition
            {
            case .rightTop:
                align = .right
                point = CGPoint(x: viewPortHandler.contentRight - xOffset,
                                y: position.y - yOffset)
                
            case .rightBottom:
                align = .right
                point = CGPoint(x: viewPortHandler.contentRight - xOffset,
                                y: position.y + yOffset - labelLineHeight)
                
            case .leftTop:
                align = .left
                point = CGPoint(x: viewPortHandler.contentLeft + xOffset,
                                y: position.y - yOffset)
                
            case .leftBottom:
                align = .left
                point = CGPoint(x: viewPortHandler.contentLeft + xOffset,
                                y: position.y + yOffset - labelLineHeight)
            }
            
            context.drawText(label,
                             at: point,
                             align: align,
                             attributes: [.font: l.valueFont, .foregroundColor: l.valueTextColor])
        }
    }
    
    @objc open func computeAxis(min: Double, max: Double, inverted: Bool)
    {
        var min = min, max = max
        
        if let transformer = self.transformer,
           viewPortHandler.contentWidth > 10.0,
           !viewPortHandler.isFullyZoomedOutY
        {
            let p1 = transformer.valueForTouchPointBarChart(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            let p2 = transformer.valueForTouchPointBarChart(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
            
            min = inverted ? Double(p1.y) : Double(p2.y)
            max = inverted ? Double(p2.y) : Double(p1.y)
        }
        
        computeAxisValues(min: min, max: max)
    }
    
    @objc open func computeAxisValues(min: Double, max: Double)
    {
        let yMin = min
        let yMax = max
        
        let labelCount = axis.labelCount
        let range = abs(yMax - yMin)
        
        guard
            labelCount != 0,
            range > 0,
            range.isFinite
        else
        {
            axis.entries = []
            axis.centeredEntries = []
            return
        }
        
        let rawInterval = range / Double(labelCount)
        var interval = rawInterval.roundedToNextSignificant()
        
        if axis.granularityEnabled
        {
            interval = Swift.max(interval, axis.granularity)
        }
        
        let intervalMagnitude = pow(10.0, Double(Int(log10(interval)))).roundedToNextSignificant()
        let intervalSigDigit = Int(interval / intervalMagnitude)
        if intervalSigDigit > 5
        {
            interval = floor(10.0 * Double(intervalMagnitude))
        }
        
        var n = axis.centerAxisLabelsEnabled ? 1 : 0
        
        if axis.isForceLabelsEnabled
        {
            interval = Double(range) / Double(labelCount - 1)
            
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)
            
            let values = stride(from: yMin, to: Double(labelCount) * interval + yMin, by: interval)
            axis.entries.append(contentsOf: values)
            
            n = labelCount
        }
        else
        {
            
            var first = interval == 0.0 ? 0.0 : ceil(yMin / interval) * interval
            
            if axis.centerAxisLabelsEnabled
            {
                first -= interval
            }
            
            let last = interval == 0.0 ? 0.0 : (floor(yMax / interval) * interval).nextUp
            
            if interval != 0.0, last != first
            {
                stride(from: first, through: last, by: interval).forEach { _ in n += 1 }
            }
            
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)
            
            let values = stride(from: first, to: Double(n) * interval + first, by: interval).map { $0 == 0.0 ? 0.0 : $0 }
            axis.entries.append(contentsOf: values)
        }
        
        if interval < 1
        {
            axis.decimals = Int(ceil(-log10(interval)))
        }
        else
        {
            axis.decimals = 0
        }
        
        if axis.centerAxisLabelsEnabled
        {
            axis.centeredEntries.reserveCapacity(n)
            axis.centeredEntries.removeAll()
            
            let offset: Double = interval / 2.0
            axis.centeredEntries.append(contentsOf: axis.entries.map { $0 + offset })
        }
    }
}

