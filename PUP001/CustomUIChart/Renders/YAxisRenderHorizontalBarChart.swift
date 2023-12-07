//
//  YAxisRendererHorizontalBarChart.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

open class YAxisRenderHorizontalBarChart: YAxisRenderBarChart
{
    public override init(viewPortHandler: ViewPortHandler, axis: YAxisChart, transformer: TransformerBarChart?)
    {
        super.init(viewPortHandler: viewPortHandler, axis: axis, transformer: transformer)
    }
    
    open override func computeAxis(min: Double, max: Double, inverted: Bool)
    {
        var min = min, max = max
        
        if let transformer = transformer,
           viewPortHandler.contentHeight > 10.0,
           !viewPortHandler.isFullyZoomedOutX
        {
            let p1 = transformer.valueForTouchPointBarChart(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            let p2 = transformer.valueForTouchPointBarChart(CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
            
            min = inverted ? Double(p2.x) : Double(p1.x)
            max = inverted ? Double(p1.x) : Double(p2.x)
        }
        
        computeAxisValues(min: min, max: max)
    }
    
    open override func renderAxisLabels(context: CGContext)
    {
        guard
            axis.isEnabled,
            axis.isDrawLabelsEnabled
        else { return }
        
        let lineHeight = axis.labelFont.lineHeight
        let baseYOffset: CGFloat = 2.5
        
        let dependency = axis.axisDependency
        let labelPosition = axis.labelPosition
        
        let yPos: CGFloat =
        {
            switch (dependency, labelPosition)
            {
            case (.left, .outsideChart):
                return viewPortHandler.contentTop - baseYOffset - lineHeight
                
            case (.left, .insideChart):
                return viewPortHandler.contentTop - baseYOffset - lineHeight
                
            case (.right, .outsideChart):
                return viewPortHandler.contentBottom + baseYOffset
                
            case (.right, .insideChart):
                return viewPortHandler.contentBottom + baseYOffset
            }
        }()
        
        drawYLabels(
            context: context,
            fixedPosition: yPos,
            positions: transformedPositions(),
            offset: axis.yOffset
        )
    }
    
    open override func renderAxisLine(context: CGContext)
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
        
        context.beginPath()
        if axis.axisDependency == .left
        {
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
        }
        else
        {
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentBottom))
        }
        context.strokePath()
    }
    
    @objc open func drawYLabels(
        context: CGContext,
        fixedPosition: CGFloat,
        positions: [CGPoint],
        offset: CGFloat)
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
                             at: CGPoint(x: positions[i].x, y: fixedPosition - offset + xOffset),
                             align: .center,
                             attributes: [.font: labelFont, .foregroundColor: labelTextColor])
        }
    }
    
    open override var gridClippingRect: CGRect
    {
        var contentRect = viewPortHandler.contentRect
        let dx = self.axis.gridLineWidth
        contentRect.origin.x -= dx / 2.0
        contentRect.size.width += dx
        return contentRect
    }
    
    open override func drawGridLine(
        context: CGContext,
        position: CGPoint)
    {
        context.beginPath()
        context.move(to: CGPoint(x: position.x, y: viewPortHandler.contentTop))
        context.addLine(to: CGPoint(x: position.x, y: viewPortHandler.contentBottom))
        context.strokePath()
    }
    
    open override func transformedPositions() -> [CGPoint]
    {
        guard let transformer = self.transformer else { return [] }
        
        var positions = axis.entries.map { CGPoint(x: $0, y: 0.0) }
        transformer.pointValuesToPixelBarChart(&positions)
        
        return positions
    }
    
    open override func drawZeroLine(context: CGContext)
    {
        guard
            let transformer = self.transformer,
            let zeroLineColor = axis.zeroLineColor
        else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        var clippingRect = viewPortHandler.contentRect
        clippingRect.origin.x -= axis.zeroLineWidth / 2.0
        clippingRect.size.width += axis.zeroLineWidth
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
        
        context.move(to: CGPoint(x: pos.x - 1.0, y: viewPortHandler.contentTop))
        context.addLine(to: CGPoint(x: pos.x - 1.0, y: viewPortHandler.contentBottom))
        context.drawPath(using: .stroke)
    }
    
    open override func renderLimitLines(context: CGContext)
    {
        guard let transformer = self.transformer else { return }
        
        let limitLines = axis.limitLines
        
        guard !limitLines.isEmpty else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        let trans = transformer.valueToPixelMatrixBarChart
        var position = CGPoint.zero
        
        for l in limitLines where l.isEnabled
        {
            context.saveGState()
            defer { context.restoreGState() }
            
            var clippingRect = viewPortHandler.contentRect
            clippingRect.origin.x -= l.lineWidth / 2.0
            clippingRect.size.width += l.lineWidth
            context.clip(to: clippingRect)
            
            position = CGPoint(x: l.limit, y: 0)
                .applying(trans)
            
            context.beginPath()
            context.move(to: CGPoint(x: position.x, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: position.x, y: viewPortHandler.contentBottom))
            
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
            
            if l.drawLabelEnabled, !label.isEmpty
            {
                let labelLineHeight = l.valueFont.lineHeight
                
                let xOffset = l.lineWidth + l.xOffset
                let yOffset = 2.0 + l.yOffset
                
                let align: TextAlignment
                let point: CGPoint
                
                switch l.labelPosition
                {
                case .rightTop:
                    align = .left
                    point = CGPoint(x: position.x + xOffset,
                                    y: viewPortHandler.contentTop + yOffset)
                    
                case .rightBottom:
                    align = .left
                    point = CGPoint(x: position.x + xOffset,
                                    y: viewPortHandler.contentBottom - labelLineHeight - yOffset)
                    
                case .leftTop:
                    align = .right
                    point = CGPoint(x: position.x - xOffset,
                                    y: viewPortHandler.contentTop + yOffset)
                    
                case .leftBottom:
                    align = .right
                    point = CGPoint(x: position.x - xOffset,
                                    y: viewPortHandler.contentBottom - labelLineHeight - yOffset)
                }
                
                context.drawText(label,
                                 at: point,
                                 align: align,
                                 attributes: [.font: l.valueFont, .foregroundColor: l.valueTextColor])
            }
        }
    }
}

