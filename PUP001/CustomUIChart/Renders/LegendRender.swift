//
//  LegendRenderer.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc(ChartLegendRenderer)
open class LegendRender: NSObject, RenderBarChart
{
    @objc public let viewPortHandler: ViewPortHandler
    
    @objc open var legend: LegendChart?
    
    @objc public init(viewPortHandler: ViewPortHandler, legend: LegendChart?)
    {
        self.viewPortHandler = viewPortHandler
        self.legend = legend
        
        super.init()
    }
    
    @objc open func computeLegend(data: DataOfChart)
    {
        guard let legend = legend else { return }
        
        if !legend.isLegendCustom
        {
            var entries: [LegendEntryChart] = []
            
            for dataSet in data
            {
                let clrs: [NSUIColor] = dataSet.colors
                let entryCount = dataSet.entryCount
                
                if dataSet is ProtocolBarChartDataSet &&
                    (dataSet as! ProtocolBarChartDataSet).isStacked
                {
                    let bds = dataSet as! ProtocolBarChartDataSet
                    let sLabels = bds.stackLabels
                    let minEntries = min(clrs.count, bds.stackSize)
                    
                    for j in 0..<minEntries
                    {
                        let label: String?
                        if !sLabels.isEmpty && minEntries > 0
                        {
                            let labelIndex = j % minEntries
                            label = sLabels.indices.contains(labelIndex) ? sLabels[labelIndex] : nil
                        }
                        else
                        {
                            label = nil
                        }
                        
                        let entry = LegendEntryChart(label: label)
                        entry.form = dataSet.form
                        entry.formSize = dataSet.formSize
                        entry.formLineWidth = dataSet.formLineWidth
                        entry.formLineDashPhase = dataSet.formLineDashPhase
                        entry.formLineDashLengths = dataSet.formLineDashLengths
                        entry.formColor = clrs[j]
                        
                        entries.append(entry)
                    }
                    
                    if dataSet.label != nil
                    {
                        let entry = LegendEntryChart(label: dataSet.label)
                        entry.form = .none
                        
                        entries.append(entry)
                    }
                }
                else
                {
                    
                    for j in 0..<min(clrs.count, entryCount)
                    {
                        let label: String?
                        
                        if j < clrs.count - 1 && j < entryCount - 1
                        {
                            label = nil
                        }
                        else
                        {
                            label = dataSet.label
                        }
                        
                        let entry = LegendEntryChart(label: label)
                        entry.form = dataSet.form
                        entry.formSize = dataSet.formSize
                        entry.formLineWidth = dataSet.formLineWidth
                        entry.formLineDashPhase = dataSet.formLineDashPhase
                        entry.formLineDashLengths = dataSet.formLineDashLengths
                        entry.formColor = clrs[j]
                        
                        entries.append(entry)
                    }
                }
            }
            
            legend.entries = entries + legend.extraEntries
        }
        
        legend.calculateDimensions(labelFont: legend.font, viewPortHandler: viewPortHandler)
    }
    
    @objc open func renderLegend(context: CGContext)
    {
        guard let legend = legend else { return }
        
        if !legend.enabled
        {
            return
        }
        
        let labelFont = legend.font
        let labelTextColor = legend.textColor
        let labelLineHeight = labelFont.lineHeight
        let formYOffset = labelLineHeight / 2.0
        
        let entries = legend.entries
        
        let defaultFormSize = legend.formSize
        let formToTextSpace = legend.formToTextSpace
        let xEntrySpace = legend.xEntrySpace
        let yEntrySpace = legend.yEntrySpace
        
        let orientation = legend.orientation
        let horizontalAlignment = legend.horizontalAlignment
        let verticalAlignment = legend.verticalAlignment
        let direction = legend.direction
        
        let stackSpace = legend.stackSpace
        
        let yoffset = legend.yOffset
        let xoffset = legend.xOffset
        var originPosX: CGFloat = 0.0
        
        switch horizontalAlignment
        {
        case .left:
            
            if orientation == .vertical
            {
                originPosX = xoffset
            }
            else
            {
                originPosX = viewPortHandler.contentLeft + xoffset
            }
            
            if direction == .rightToLeft
            {
                originPosX += legend.neededWidth
            }
            
        case .right:
            
            if orientation == .vertical
            {
                originPosX = viewPortHandler.chartWidth - xoffset
            }
            else
            {
                originPosX = viewPortHandler.contentRight - xoffset
            }
            
            if direction == .leftToRight
            {
                originPosX -= legend.neededWidth
            }
            
        case .center:
            
            if orientation == .vertical
            {
                originPosX = viewPortHandler.chartWidth / 2.0
            }
            else
            {
                originPosX = viewPortHandler.contentLeft
                + viewPortHandler.contentWidth / 2.0
            }
            
            originPosX += (direction == .leftToRight
                           ? +xoffset
                           : -xoffset)
            
            if orientation == .vertical
            {
                if direction == .leftToRight
                {
                    originPosX -= legend.neededWidth / 2.0 - xoffset
                }
                else
                {
                    originPosX += legend.neededWidth / 2.0 - xoffset
                }
            }
        }
        
        switch orientation
        {
        case .horizontal:
            
            let calculatedLineSizes = legend.calculatedLineSizes
            let calculatedLabelSizes = legend.calculatedLabelSizes
            let calculatedLabelBreakPoints = legend.calculatedLabelBreakPoints
            
            var posX: CGFloat = originPosX
            var posY: CGFloat
            
            switch verticalAlignment
            {
            case .top:
                posY = yoffset
                
            case .bottom:
                posY = viewPortHandler.chartHeight - yoffset - legend.neededHeight
                
            case .center:
                posY = (viewPortHandler.chartHeight - legend.neededHeight) / 2.0 + yoffset
            }
            
            var lineIndex: Int = 0
            
            for i in entries.indices
            {
                let e = entries[i]
                let drawingForm = e.form != .none
                let formSize = e.formSize.isNaN ? defaultFormSize : e.formSize
                
                if i < calculatedLabelBreakPoints.endIndex &&
                    calculatedLabelBreakPoints[i]
                {
                    posX = originPosX
                    posY += labelLineHeight + yEntrySpace
                }
                
                if posX == originPosX &&
                    horizontalAlignment == .center &&
                    lineIndex < calculatedLineSizes.endIndex
                {
                    posX += (direction == .rightToLeft
                             ? calculatedLineSizes[lineIndex].width
                             : -calculatedLineSizes[lineIndex].width) / 2.0
                    lineIndex += 1
                }
                
                let isStacked = e.label == nil
                if drawingForm
                {
                    if direction == .rightToLeft
                    {
                        posX -= formSize
                    }
                    
                    drawForm(
                        context: context,
                        x: posX,
                        y: posY + formYOffset,
                        entry: e,
                        legend: legend)
                    
                    if direction == .leftToRight
                    {
                        posX += formSize
                    }
                }
                
                if !isStacked
                {
                    if drawingForm
                    {
                        posX += direction == .rightToLeft ? -formToTextSpace : formToTextSpace
                    }
                    
                    if direction == .rightToLeft
                    {
                        posX -= calculatedLabelSizes[i].width
                    }
                    
                    drawLabel(
                        context: context,
                        x: posX,
                        y: posY,
                        label: e.label!,
                        font: labelFont,
                        textColor: e.labelColor ?? labelTextColor)
                    
                    if direction == .leftToRight
                    {
                        posX += calculatedLabelSizes[i].width
                    }
                    
                    posX += direction == .rightToLeft ? -xEntrySpace : xEntrySpace
                }
                else
                {
                    posX += direction == .rightToLeft ? -stackSpace : stackSpace
                }
            }
            
        case .vertical:
            
            var stack = CGFloat(0.0)
            var wasStacked = false
            
            var posY: CGFloat = 0.0
            
            switch verticalAlignment
            {
            case .top:
                posY = (horizontalAlignment == .center
                        ? 0.0
                        : viewPortHandler.contentTop)
                posY += yoffset
                
            case .bottom:
                posY = (horizontalAlignment == .center
                        ? viewPortHandler.chartHeight
                        : viewPortHandler.contentBottom)
                posY -= legend.neededHeight + yoffset
                
            case .center:
                
                posY = viewPortHandler.chartHeight / 2.0 - legend.neededHeight / 2.0 + legend.yOffset
            }
            
            for i in entries.indices
            {
                let e = entries[i]
                let drawingForm = e.form != .none
                let formSize = e.formSize.isNaN ? defaultFormSize : e.formSize
                
                var posX = originPosX
                
                if drawingForm
                {
                    if direction == .leftToRight
                    {
                        posX += stack
                    }
                    else
                    {
                        posX -= formSize - stack
                    }
                    
                    drawForm(
                        context: context,
                        x: posX,
                        y: posY + formYOffset,
                        entry: e,
                        legend: legend)
                    
                    if direction == .leftToRight
                    {
                        posX += formSize
                    }
                }
                
                if e.label != nil
                {
                    if drawingForm && !wasStacked
                    {
                        posX += direction == .leftToRight ? formToTextSpace : -formToTextSpace
                    }
                    else if wasStacked
                    {
                        posX = originPosX
                    }
                    
                    if direction == .rightToLeft
                    {
                        posX -= (e.label! as NSString).size(withAttributes: [.font: labelFont]).width
                    }
                    
                    if !wasStacked
                    {
                        drawLabel(context: context, x: posX, y: posY, label: e.label!, font: labelFont, textColor: e.labelColor ?? labelTextColor)
                    }
                    else
                    {
                        posY += labelLineHeight + yEntrySpace
                        drawLabel(context: context, x: posX, y: posY, label: e.label!, font: labelFont, textColor: e.labelColor ?? labelTextColor)
                    }
                    
                    posY += labelLineHeight + yEntrySpace
                    stack = 0.0
                }
                else
                {
                    stack += formSize + stackSpace
                    wasStacked = true
                }
            }
        }
    }
    
    private var _formLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    @objc open func drawForm(
        context: CGContext,
        x: CGFloat,
        y: CGFloat,
        entry: LegendEntryChart,
        legend: LegendChart)
    {
        guard
            let formColor = entry.formColor,
            formColor != NSUIColor.clear
        else { return }
        
        var form = entry.form
        if form == .default
        {
            form = legend.form
        }
        
        let formSize = entry.formSize.isNaN ? legend.formSize : entry.formSize
        
        context.saveGState()
        defer { context.restoreGState() }
        
        switch form
        {
        case .none:
            break
            
        case .empty:
            break
            
        case .default: fallthrough
        case .circle:
            
            context.setFillColor(formColor.cgColor)
            context.fillEllipse(in: CGRect(x: x, y: y - formSize / 2.0, width: formSize, height: formSize))
            
        case .square:
            
            context.setFillColor(formColor.cgColor)
            context.fill(CGRect(x: x, y: y - formSize / 2.0, width: formSize, height: formSize))
            
        case .line:
            
            let formLineWidth = entry.formLineWidth.isNaN ? legend.formLineWidth : entry.formLineWidth
            let formLineDashPhase = entry.formLineDashPhase.isNaN ? legend.formLineDashPhase : entry.formLineDashPhase
            let formLineDashLengths = entry.formLineDashLengths == nil ? legend.formLineDashLengths : entry.formLineDashLengths
            
            context.setLineWidth(formLineWidth)
            
            if formLineDashLengths != nil && !formLineDashLengths!.isEmpty
            {
                context.setLineDash(phase: formLineDashPhase, lengths: formLineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            context.setStrokeColor(formColor.cgColor)
            
            _formLineSegmentsBuffer[0].x = x
            _formLineSegmentsBuffer[0].y = y
            _formLineSegmentsBuffer[1].x = x + formSize
            _formLineSegmentsBuffer[1].y = y
            context.strokeLineSegments(between: _formLineSegmentsBuffer)
        }
    }
    
    @objc open func drawLabel(context: CGContext, x: CGFloat, y: CGFloat, label: String, font: NSUIFont, textColor: NSUIColor)
    {
        context.drawText(label, at: CGPoint(x: x, y: y), align: .left, attributes: [.font: font, .foregroundColor: textColor])
    }
}

