//
//  XAxisRenderer.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics


@objc(ChartXAxisRenderer)
open class XAxisRenderBarChart: NSObject, AxisRenderBarChart
{
    @objc public let viewPortHandler: ViewPortHandler
    @objc public let axis: XAxisChart
    @objc public let transformer: TransformerBarChart?
    
    @objc public init(viewPortHandler: ViewPortHandler, axis: XAxisChart, transformer: TransformerBarChart?)
    {
        self.viewPortHandler = viewPortHandler
        self.axis = axis
        self.transformer = transformer
        
        super.init()
    }
    
    open func computeAxis(min: Double, max: Double, inverted: Bool)
    {
        var min = min, max = max
        
        if let transformer = self.transformer,
           viewPortHandler.contentWidth > 10,
           !viewPortHandler.isFullyZoomedOutX
        {
            let p1 = transformer.valueForTouchPointBarChart(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            let p2 = transformer.valueForTouchPointBarChart(CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
            
            min = inverted ? Double(p2.x) : Double(p1.x)
            max = inverted ? Double(p1.x) : Double(p2.x)
        }
        
        computeAxisValues(min: min, max: max)
    }
    
    open func computeAxisValues(min: Double, max: Double)
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
            interval = range / Double(labelCount - 1)
            
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
            
            let start = first, end = first + Double(n) * interval
            
            let values = stride(from: start, to: end, by: interval).map { $0 == 0.0 ? 0.0 : $0 }
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
            let offset: Double = interval / 2.0
            axis.centeredEntries = axis.entries[..<n]
                .map { $0 + offset }
        }
        
        computeSize()
    }
    
    @objc open func computeSize()
    {
        let longest = axis.getLongestLabel()
        
        let labelSize = longest.size(withAttributes: [.font: axis.labelFont])
        
        let labelWidth = labelSize.width
        let labelHeight = labelSize.height
        
        let labelRotatedSize = labelSize.rotatedBy(degrees: axis.labelRotationAngle)
        
        axis.labelWidth = labelWidth
        axis.labelHeight = labelHeight
        axis.labelRotatedWidth = labelRotatedSize.width
        axis.labelRotatedHeight = labelRotatedSize.height
    }
    
    open func renderAxisLabels(context: CGContext)
    {
        guard
            axis.isEnabled,
            axis.isDrawLabelsEnabled
        else { return }
        
        let yOffset = axis.yOffset
        
        switch axis.labelPosition {
        case .top:
            drawLabels(context: context, pos: viewPortHandler.contentTop - yOffset, anchor: CGPoint(x: 0.5, y: 1.0))
            
        case .topInside:
            drawLabels(context: context, pos: viewPortHandler.contentTop + yOffset + axis.labelRotatedHeight, anchor: CGPoint(x: 0.5, y: 1.0))
            
        case .bottom:
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yOffset, anchor: CGPoint(x: 0.5, y: 0.0))
            
        case .bottomInside:
            drawLabels(context: context, pos: viewPortHandler.contentBottom - yOffset - axis.labelRotatedHeight, anchor: CGPoint(x: 0.5, y: 0.0))
            
        case .bothSided:
            drawLabels(context: context, pos: viewPortHandler.contentTop - yOffset, anchor: CGPoint(x: 0.5, y: 1.0))
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yOffset, anchor: CGPoint(x: 0.5, y: 0.0))
        }
    }
    
    private var axisLineSegmentsBuffer = [CGPoint](repeating: .zero, count: 2)
    
    open func renderAxisLine(context: CGContext)
    {
        guard
            axis.isEnabled,
            axis.isDrawAxisLineEnabled
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
        
        if axis.labelPosition == .top
            || axis.labelPosition == .topInside
            || axis.labelPosition == .bothSided
        {
            axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            axisLineSegmentsBuffer[1].y = viewPortHandler.contentTop
            context.strokeLineSegments(between: axisLineSegmentsBuffer)
        }
        
        if axis.labelPosition == .bottom
            || axis.labelPosition == .bottomInside
            || axis.labelPosition == .bothSided
        {
            axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            axisLineSegmentsBuffer[0].y = viewPortHandler.contentBottom
            axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            context.strokeLineSegments(between: axisLineSegmentsBuffer)
        }
    }
    
    @objc open func drawLabels(context: CGContext, pos: CGFloat, anchor: CGPoint)
    {
        guard let transformer = self.transformer else { return }
        
        let paraStyle = ParagraphStyle.default.mutableCopy() as! MutableParagraphStyle
        paraStyle.alignment = .center
        
        let labelAttrs: [NSAttributedString.Key : Any] = [.font: axis.labelFont,
                                                          .foregroundColor: axis.labelTextColor,
                                                          .paragraphStyle: paraStyle]
        
        let labelRotationAngleRadians = axis.labelRotationAngle.DEG2RAD
        let isCenteringEnabled = axis.isCenterAxisLabelsEnabled
        let valueToPixelMatrix = transformer.valueToPixelMatrixBarChart
        
        var position = CGPoint.zero
        var labelMaxSize = CGSize.zero
        
        if axis.isWordWrapEnabled
        {
            labelMaxSize.width = axis.wordWrapWidthPercent * valueToPixelMatrix.a
        }
        
        let entries = axis.entries
        
        for i in entries.indices
        {
            let px = isCenteringEnabled ? CGFloat(axis.centeredEntries[i]) : CGFloat(entries[i])
            position = CGPoint(x: px, y: 0)
                .applying(valueToPixelMatrix)
            
            guard viewPortHandler.isInBoundsX(position.x) else { continue }
            
            let label = axis.valueFormatter?.stringForValue(axis.entries[i], axis: axis) ?? ""
            let labelns = label as NSString
            
            if axis.isAvoidFirstLastClippingEnabled
            {
                if i == axis.entryCount - 1 && axis.entryCount > 1
                {
                    print("AAAAA")
                }
                else if i == 0
                {
                    print("BBBBB")
                }
            }
            
            drawLabel(context: context,
                      formattedLabel: label,
                      x: position.x,
                      y: pos,
                      attributes: labelAttrs,
                      constrainedTo: labelMaxSize,
                      anchor: anchor,
                      angleRadians: labelRotationAngleRadians)
        }
    }
    
    @objc open func drawLabel(
        context: CGContext,
        formattedLabel: String,
        x: CGFloat,
        y: CGFloat,
        attributes: [NSAttributedString.Key : Any],
        constrainedTo size: CGSize,
        anchor: CGPoint,
        angleRadians: CGFloat)
    {
        context.drawMultilineText(formattedLabel,
                                  at: CGPoint(x: x, y: y),
                                  constrainedTo: size,
                                  anchor: anchor,
                                  angleRadians: angleRadians,
                                  attributes: attributes)
    }
    
    open func renderGridLines(context: CGContext)
    {
        guard
            let transformer = self.transformer,
            axis.isEnabled,
            axis.isDrawGridLinesEnabled
        else { return }
        
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
        
        let valueToPixelMatrix = transformer.valueToPixelMatrixBarChart
        
        var position = CGPoint.zero
        
        let entries = axis.entries
        
        for entry in entries
        {
            position.x = CGFloat(entry)
            position.y = CGFloat(entry)
            position = position.applying(valueToPixelMatrix)
            
            drawGridLine(context: context, x: position.x, y: position.y)
        }
    }
    
    @objc open var gridClippingRect: CGRect
    {
        var contentRect = viewPortHandler.contentRect
        let dx = self.axis.gridLineWidth
        contentRect.origin.x -= dx / 2.0
        contentRect.size.width += dx
        return contentRect
    }
    
    @objc open func drawGridLine(context: CGContext, x: CGFloat, y: CGFloat)
    {
        guard x >= viewPortHandler.offsetLeft && x <= viewPortHandler.chartWidth else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: x, y: viewPortHandler.contentTop))
        context.addLine(to: CGPoint(x: x, y: viewPortHandler.contentBottom))
        context.strokePath()
    }
    
    open func renderLimitLines(context: CGContext)
    {
        guard
            let transformer = self.transformer,
            !axis.limitLines.isEmpty
        else { return }
        
        let trans = transformer.valueToPixelMatrixBarChart
        
        var position = CGPoint.zero
        
        for l in axis.limitLines where l.isEnabled
        {
            context.saveGState()
            defer { context.restoreGState() }
            
            var clippingRect = viewPortHandler.contentRect
            clippingRect.origin.x -= l.lineWidth / 2.0
            clippingRect.size.width += l.lineWidth
            context.clip(to: clippingRect)
            
            position.x = CGFloat(l.limit)
            position.y = 0.0
            position = position.applying(trans)
            
            renderLimitLineLine(context: context, limitLine: l, position: position)
            renderLimitLineLabel(context: context, limitLine: l, position: position, yOffset: 2.0 + l.yOffset)
        }
    }
    
    @objc open func renderLimitLineLine(context: CGContext, limitLine: ChartLimitLineChart, position: CGPoint)
    {
        context.beginPath()
        context.move(to: CGPoint(x: position.x, y: viewPortHandler.contentTop))
        context.addLine(to: CGPoint(x: position.x, y: viewPortHandler.contentBottom))
        
        context.setStrokeColor(limitLine.lineColor.cgColor)
        context.setLineWidth(limitLine.lineWidth)
        if limitLine.lineDashLengths != nil
        {
            context.setLineDash(phase: limitLine.lineDashPhase, lengths: limitLine.lineDashLengths!)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        context.strokePath()
    }
    
    @objc open func renderLimitLineLabel(context: CGContext, limitLine: ChartLimitLineChart, position: CGPoint, yOffset: CGFloat)
    {
        let label = limitLine.label
        
        guard limitLine.drawLabelEnabled, !label.isEmpty else { return }
        
        let labelLineHeight = limitLine.valueFont.lineHeight
        
        let xOffset: CGFloat = limitLine.lineWidth + limitLine.xOffset
        
        let align: TextAlignment
        let point: CGPoint
        
        switch limitLine.labelPosition
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
                         attributes: [.font: limitLine.valueFont,
                                      .foregroundColor: limitLine.valueTextColor])
    }
}

