//
//  BarChartRenderer.swift
//  PUP001
//
//  Created by chuottp on 19/08/2023.
//

import Foundation
import CoreGraphics
import UIKit


open class BarChartRender: BarLineScatterCandleBubbleRender
{
    
    internal lazy var accessibilityOrderedElements: [[NSUIAccessibilityElement]] = accessibilityCreateEmptyOrderedElements()
    
    private typealias Buffer = [CGRect]
    
    @objc open weak var dataProvider: DataProviderBarChart?
    
    @objc public init(dataProvider: DataProviderBarChart, animator: AnimatorChart, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    private var _buffers = [Buffer]()
    
    open override func initBuffers()
    {
        guard let barData = dataProvider?.barData else { return _buffers.removeAll() }
        
        if _buffers.count != barData.count
        {
            while _buffers.count < barData.count
            {
                _buffers.append(Buffer())
            }
            while _buffers.count > barData.count
            {
                _buffers.removeLast()
            }
        }
        
        _buffers = zip(_buffers, barData).map { buffer, set -> Buffer in
            let set = set as! ProtocolBarChartDataSet
            let size = set.entryCount * (set.isStacked ? set.stackSize : 1)
            return buffer.count == size
            ? buffer
            : Buffer(repeating: .zero, count: size)
        }
    }
    
    private func prepareBuffer(dataSet: ProtocolBarChartDataSet, index: Int)
    {
        guard
            let dataProvider = dataProvider,
            let barData = dataProvider.barData
        else { return }
        
        let barWidthHalf = CGFloat(barData.barWidth / 2.0)
        
        var bufferIndex = 0
        let containsStacks = dataSet.isStacked
        
        let isInverted = dataProvider.isInverted(axis: dataSet.axisDependency)
        let phaseY = CGFloat(animator.phaseY)
        
        for i in (0..<dataSet.entryCount).clamped(to: 0..<Int(ceil(Double(dataSet.entryCount) * animator.phaseX)))
        {
            guard let e = dataSet.entryForIndex(i) as? DataEntryBarChart else { continue }
            
            let x = CGFloat(e.x)
            let left = x - barWidthHalf
            let right = x + barWidthHalf
            
            var y = e.y
            
            if containsStacks, let vals = e.yValues
            {
                var posY = 0.0
                var negY = -e.negativeSum
                var yStart = 0.0
                
                for value in vals
                {
                    if value == 0.0 && (posY == 0.0 || negY == 0.0)
                    {
                        y = value
                        yStart = y
                    }
                    else if value >= 0.0
                    {
                        y = posY
                        yStart = posY + value
                        posY = yStart
                    }
                    else
                    {
                        y = negY
                        yStart = negY + abs(value)
                        negY += abs(value)
                    }
                    
                    var top = isInverted
                    ? (y <= yStart ? CGFloat(y) : CGFloat(yStart))
                    : (y >= yStart ? CGFloat(y) : CGFloat(yStart))
                    var bottom = isInverted
                    ? (y >= yStart ? CGFloat(y) : CGFloat(yStart))
                    : (y <= yStart ? CGFloat(y) : CGFloat(yStart))
                    
                    top *= phaseY
                    bottom *= phaseY
                    
                    let barRect = CGRect(x: left, y: top,
                                         width: right - left,
                                         height: bottom - top)
                    _buffers[index][bufferIndex] = barRect
                    bufferIndex += 1
                }
            }
            else
            {
                var top = isInverted
                ? (y <= 0.0 ? CGFloat(y) : 0)
                : (y >= 0.0 ? CGFloat(y) : 0)
                var bottom = isInverted
                ? (y >= 0.0 ? CGFloat(y) : 0)
                : (y <= 0.0 ? CGFloat(y) : 0)
                
                var topOffset: CGFloat = 0.0
                var bottomOffset: CGFloat = 0.0
                if let offsetView = dataProvider as? BarChartView
                {
                    let offsetAxis = offsetView.getAxis(dataSet.axisDependency)
                    if y >= 0
                    {
                        // situation 1
                        if offsetAxis.axisMaximum < y
                        {
                            topOffset = CGFloat(y - offsetAxis.axisMaximum)
                        }
                        if offsetAxis.axisMinimum > 0
                        {
                            bottomOffset = CGFloat(offsetAxis.axisMinimum)
                        }
                    }
                    else
                    {
                        if offsetAxis.axisMaximum < 0
                        {
                            topOffset = CGFloat(offsetAxis.axisMaximum * -1)
                        }
                        if offsetAxis.axisMinimum > y
                        {
                            bottomOffset = CGFloat(offsetAxis.axisMinimum - y)
                        }
                    }
                    if isInverted
                    {
                        (topOffset, bottomOffset) = (bottomOffset, topOffset)
                    }
                }
                top = isInverted ? top + topOffset : top - topOffset
                bottom = isInverted ? bottom - bottomOffset : bottom + bottomOffset
                if top > 0 + topOffset
                {
                    top *= phaseY
                }
                else
                {
                    bottom *= phaseY
                }
                
                let barRect = CGRect(x: left, y: top,
                                     width: right - left,
                                     height: bottom - top)
                _buffers[index][bufferIndex] = barRect
                bufferIndex += 1
            }
        }
    }
    
    open override func drawData(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let barData = dataProvider.barData
        else { return }
        
        accessibleChartElements.removeAll()
        accessibilityOrderedElements = accessibilityCreateEmptyOrderedElements()
        
        if let chart = dataProvider as? BarChartView {
            let element = createAccessibleHeader(usingChart: chart,
                                                 andData: barData,
                                                 withDefaultDescription: "Bar Chart")
            accessibleChartElements.append(element)
        }
        
        for i in barData.indices
        {
            guard let set = barData[i] as? ProtocolBarChartDataSet else {
                fatalError("Datasets for BarChartRenderer must conform to IBarChartDataset")
            }
            
            guard set.isVisible else { continue }
            
            drawDataSet(context: context, dataSet: set, index: i)
        }
        
        accessibleChartElements.append(contentsOf: accessibilityOrderedElements.flatMap { $0 } )
        accessibilityPostLayoutChangedNotification()
    }
    
    private var _barShadowRectBuffer: CGRect = CGRect()
    
    @objc open func drawDataSet(context: CGContext, dataSet: ProtocolBarChartDataSet, index: Int)
    {
        guard let dataProvider = dataProvider else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        prepareBuffer(dataSet: dataSet, index: index)
        trans.rectValuesToPixelBarChart(&_buffers[index])
        
        let borderWidth = dataSet.barBorderWidth
        let borderColor = dataSet.barBorderColor
        let drawBorder = borderWidth > 0.0
        
        context.saveGState()
        defer { context.restoreGState() }
        
        if dataProvider.isDrawBarShadowEnabled
        {
            guard let barData = dataProvider.barData else { return }
            
            let barWidth = barData.barWidth
            let barWidthHalf = barWidth / 2.0
            var x: Double = 0.0
            
            let range = (0..<dataSet.entryCount).clamped(to: 0..<Int(ceil(Double(dataSet.entryCount) * animator.phaseX)))
            for i in range
            {
                guard let e = dataSet.entryForIndex(i) as? DataEntryBarChart else { continue }
                
                x = e.x
                
                _barShadowRectBuffer.origin.x = CGFloat(x - barWidthHalf)
                _barShadowRectBuffer.size.width = CGFloat(barWidth)
                
                trans.rectValueToPixelBarChart(&_barShadowRectBuffer)
                
                guard viewPortHandler.isInBoundsLeft(_barShadowRectBuffer.origin.x + _barShadowRectBuffer.size.width) else { continue }
                
                guard viewPortHandler.isInBoundsRight(_barShadowRectBuffer.origin.x) else { break }
                
                _barShadowRectBuffer.origin.y = viewPortHandler.contentTop
                _barShadowRectBuffer.size.height = viewPortHandler.contentHeight
                
                context.setFillColor(dataSet.barShadowColor.cgColor)
                context.fill(_barShadowRectBuffer)
            }
        }
        
        let buffer = _buffers[index]
        
        if dataProvider.isDrawBarShadowEnabled
        {
            for barRect in buffer where viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width)
            {
                guard viewPortHandler.isInBoundsRight(barRect.origin.x) else { break }
                
                context.setFillColor(dataSet.barShadowColor.cgColor)
                context.fill(barRect)
            }
        }
        
        let isSingleColor = dataSet.colors.count == 1
        
        if isSingleColor
        {
            context.setFillColor(dataSet.color(atIndex: 0).cgColor)
        }
        
        let isStacked = dataSet.isStacked
        let stackSize = isStacked ? dataSet.stackSize : 1
        
        for j in buffer.indices
        {
            let barRect = buffer[j]
            
            guard viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width) else { continue }
            guard viewPortHandler.isInBoundsRight(barRect.origin.x) else { break }
            
            if !isSingleColor
            {
                context.setFillColor(dataSet.color(atIndex: j).cgColor)
            }
            let bezierPath = UIBezierPath(roundedRect: barRect, cornerRadius: 3.0)
            context.addPath(bezierPath.cgPath)
            context.drawPath(using: .fill)
            
            if drawBorder
            {
                context.setStrokeColor(borderColor.cgColor)
                context.setLineWidth(borderWidth)
                context.stroke(barRect)
            }
            
            if let chart = dataProvider as? BarChartView
            {
                let element = createAccessibleElement(
                    withIndex: j,
                    container: chart,
                    dataSet: dataSet,
                    dataSetIndex: index,
                    stackSize: stackSize
                ) { (element) in
                    element.accessibilityFrame = barRect
                }
                
                accessibilityOrderedElements[j/stackSize].append(element)
            }
        }
    }
    
    open func prepareBarHighlight(
        x: Double,
        y1: Double,
        y2: Double,
        barWidthHalf: Double,
        trans: TransformerBarChart,
        rect: inout CGRect)
    {
        let left = x - barWidthHalf
        let right = x + barWidthHalf
        let top = y1
        let bottom = y2
        
        rect.origin.x = CGFloat(left)
        rect.origin.y = CGFloat(top)
        rect.size.width = CGFloat(right - left)
        rect.size.height = CGFloat(bottom - top)
        
        trans.rectValueToPixelBarChart(&rect, phaseY: animator.phaseY )
    }
    
    open override func drawValues(context: CGContext)
    {
        if isDrawingValuesAllowed(dataProvider: dataProvider)
        {
            guard
                let dataProvider = dataProvider,
                let barData = dataProvider.barData
            else { return }
            
            let valueOffsetPlus: CGFloat = 4.5
            var posOffset: CGFloat
            var negOffset: CGFloat
            let drawValueAboveBar = dataProvider.isDrawValueAboveBarEnabled
            
            for dataSetIndex in barData.indices
            {
                guard
                    let dataSet = barData[dataSetIndex] as? ProtocolBarChartDataSet,
                    shouldDrawValues(forDataSet: dataSet)
                else { continue }
                
                let angleRadians = dataSet.valueLabelAngle.DEG2RAD
                
                let isInverted = dataProvider.isInverted(axis: dataSet.axisDependency)
                
                let valueFont = dataSet.valueFont
                let valueTextHeight = valueFont.lineHeight
                posOffset = (drawValueAboveBar ? -(valueTextHeight + valueOffsetPlus) : valueOffsetPlus)
                negOffset = (drawValueAboveBar ? valueOffsetPlus : -(valueTextHeight + valueOffsetPlus))
                
                if isInverted
                {
                    posOffset = -posOffset - valueTextHeight
                    negOffset = -negOffset - valueTextHeight
                }
                
                let buffer = _buffers[dataSetIndex]
                
                let formatter = dataSet.valueFormatter
                
                let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
                
                let phaseY = animator.phaseY
                
                let iconsOffset = dataSet.iconsOffset
                
                if !dataSet.isStacked
                {
                    let range = 0 ..< Int(ceil(Double(dataSet.entryCount) * animator.phaseX))
                    for j in range
                    {
                        guard let e = dataSet.entryForIndex(j) as? DataEntryBarChart else { continue }
                        
                        let rect = buffer[j]
                        
                        let x = rect.origin.x + rect.size.width / 2.0
                        
                        guard viewPortHandler.isInBoundsRight(x) else { break }
                        
                        guard viewPortHandler.isInBoundsY(rect.origin.y),
                              viewPortHandler.isInBoundsLeft(x)
                        else { continue }
                        
                        let val = e.y
                        
                        if dataSet.isDrawValuesEnabled
                        {
                            drawValue(
                                context: context,
                                value: formatter.stringForValue(
                                    val,
                                    entry: e,
                                    dataSetIndex: dataSetIndex,
                                    viewPortHandler: viewPortHandler),
                                xPos: x,
                                yPos: val >= 0.0
                                ? (rect.origin.y + posOffset)
                                : (rect.origin.y + rect.size.height + negOffset),
                                font: valueFont,
                                align: .center,
                                color: dataSet.valueTextColorAt(j),
                                anchor: CGPoint(x: 0.5, y: 0.5),
                                angleRadians: angleRadians)
                        }
                        
                        if let icon = e.icon, dataSet.isDrawIconsEnabled
                        {
                            var px = x
                            var py = val >= 0.0
                            ? (rect.origin.y + posOffset)
                            : (rect.origin.y + rect.size.height + negOffset)
                            
                            px += iconsOffset.x
                            py += iconsOffset.y
                            
                            context.drawImage(icon,
                                              atCenter: CGPoint(x: px, y: py),
                                              size: icon.size)
                        }
                        
                    }
                }
                else
                {
                    
                    var bufferIndex = 0
                    let lastIndex = ceil(Double(dataSet.entryCount) * animator.phaseX)
                    
                    for index in 0 ..< Int(lastIndex)
                    {
                        guard let e = dataSet.entryForIndex(index) as? DataEntryBarChart else { continue }
                        
                        let vals = e.yValues
                        
                        let rect = buffer[bufferIndex]
                        
                        let x = rect.origin.x + rect.size.width / 2.0
                        
                        if let values = vals
                        {
                            var transformed = [CGPoint]()
                            
                            var posY = 0.0
                            var negY = -e.negativeSum
                            
                            for value in values
                            {
                                let y: Double
                                
                                if value == 0.0 && (posY == 0.0 || negY == 0.0)
                                {
                                    y = value
                                }
                                else if value >= 0.0
                                {
                                    posY += value
                                    y = posY
                                }
                                else
                                {
                                    y = negY
                                    negY -= value
                                }
                                
                                transformed.append(CGPoint(x: 0.0, y: CGFloat(y * phaseY)))
                            }
                            
                            trans.pointValuesToPixelBarChart(&transformed)
                            
                            for (value, transformed) in zip(values, transformed)
                            {
                                let drawBelow = (value == 0.0 && negY == 0.0 && posY > 0.0) || value < 0.0
                                let y = transformed.y + (drawBelow ? negOffset : posOffset)
                                
                                guard viewPortHandler.isInBoundsRight(x) else { break }
                                guard viewPortHandler.isInBoundsY(y),
                                      viewPortHandler.isInBoundsLeft(x)
                                else { continue }
                                
                                if dataSet.isDrawValuesEnabled
                                {
                                    drawValue(
                                        context: context,
                                        value: formatter.stringForValue(
                                            value,
                                            entry: e,
                                            dataSetIndex: dataSetIndex,
                                            viewPortHandler: viewPortHandler),
                                        xPos: x,
                                        yPos: y,
                                        font: valueFont,
                                        align: .center,
                                        color: dataSet.valueTextColorAt(index),
                                        anchor: CGPoint(x: 0.5, y: 0.5),
                                        angleRadians: angleRadians)
                                }
                                
                                if let icon = e.icon, dataSet.isDrawIconsEnabled
                                {
                                    context.drawImage(icon,
                                                      atCenter: CGPoint(x: x + iconsOffset.x,
                                                                        y: y + iconsOffset.y),
                                                      size: icon.size)
                                }
                            }
                        }
                        else
                        {
                            guard viewPortHandler.isInBoundsRight(x) else { break }
                            guard viewPortHandler.isInBoundsY(rect.origin.y),
                                  viewPortHandler.isInBoundsLeft(x) else { continue }
                            
                            if dataSet.isDrawValuesEnabled
                            {
                                drawValue(
                                    context: context,
                                    value: formatter.stringForValue(
                                        e.y,
                                        entry: e,
                                        dataSetIndex: dataSetIndex,
                                        viewPortHandler: viewPortHandler),
                                    xPos: x,
                                    yPos: rect.origin.y +
                                    (e.y >= 0 ? posOffset : negOffset),
                                    font: valueFont,
                                    align: .center,
                                    color: dataSet.valueTextColorAt(index),
                                    anchor: CGPoint(x: 0.5, y: 0.5),
                                    angleRadians: angleRadians)
                            }
                            
                            if let icon = e.icon, dataSet.isDrawIconsEnabled
                            {
                                var px = x
                                var py = rect.origin.y +
                                (e.y >= 0 ? posOffset : negOffset)
                                
                                px += iconsOffset.x
                                py += iconsOffset.y
                                
                                context.drawImage(icon,
                                                  atCenter: CGPoint(x: px, y: py),
                                                  size: icon.size)
                            }
                        }
                        
                        bufferIndex += vals?.count ?? 1
                    }
                }
            }
        }
    }
    
    @objc open func drawValue(context: CGContext, value: String, xPos: CGFloat, yPos: CGFloat, font: NSUIFont, align: TextAlignment, color: NSUIColor, anchor: CGPoint, angleRadians: CGFloat)
    {
        if (angleRadians == 0.0)
        {
            context.drawText(value, at: CGPoint(x: xPos, y: yPos), align: align, attributes: [.font: font, .foregroundColor: color])
        }
        else
        {
            context.drawText(value, at: CGPoint(x: xPos, y: yPos), align: align, anchor: anchor, angleRadians: angleRadians, attributes: [.font: font, .foregroundColor: color])
        }
    }
    
    
    open override func drawExtras(context: CGContext)
    {
        
    }
    
    open override func drawHighlighted(context: CGContext, indices: [HighlightChart])
    {
        guard
            let dataProvider = dataProvider,
            let barData = dataProvider.barData
        else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        var barRect = CGRect()
        
        for high in indices
        {
            guard
                let set = barData[high.dataSetIndex] as? ProtocolBarChartDataSet,
                set.isHighlightEnabled
            else { continue }
            
            if let e = set.entryForXValue(high.x, closestToY: high.y) as? DataEntryBarChart
            {
                guard isInBoundsX(entry: e, dataSet: set) else { continue }
                
                let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
                
                context.setFillColor(set.highlightColor.cgColor)
                context.setAlpha(set.highlightAlpha)
                
                let isStack = high.stackIndex >= 0 && e.isStacked
                
                let y1: Double
                let y2: Double
                
                if isStack
                {
                    if dataProvider.isHighlightFullBarEnabled
                    {
                        y1 = e.positiveSum
                        y2 = -e.negativeSum
                    }
                    else
                    {
                        let range = e.ranges?[high.stackIndex]
                        
                        y1 = range?.from ?? 0.0
                        y2 = range?.to ?? 0.0
                    }
                }
                else
                {
                    y1 = e.y
                    y2 = 0.0
                }
                
                prepareBarHighlight(x: e.x, y1: y1, y2: y2, barWidthHalf: barData.barWidth / 2.0, trans: trans, rect: &barRect)
                
                setHighlightDrawPos(highlight: high, barRect: barRect)
                
                context.fill(barRect)
            }
        }
    }
    
    internal func setHighlightDrawPos(highlight high: HighlightChart, barRect: CGRect)
    {
        high.setDraw(x: barRect.midX, y: barRect.origin.y)
    }
    
    internal func accessibilityCreateEmptyOrderedElements() -> [[NSUIAccessibilityElement]]
    {
        guard let chart = dataProvider as? BarChartView else { return [] }
        
        let maxEntryCount = chart.data?.maxEntryCountSet?.entryCount ?? 0
        
        return Array(repeating: [NSUIAccessibilityElement](),
                     count: maxEntryCount)
    }
    
    internal func createAccessibleElement(withIndex idx: Int,
                                          container: BarChartView,
                                          dataSet: ProtocolBarChartDataSet,
                                          dataSetIndex: Int,
                                          stackSize: Int,
                                          modifier: (NSUIAccessibilityElement) -> ()) -> NSUIAccessibilityElement
    {
        let element = NSUIAccessibilityElement(accessibilityContainer: container)
        let xAxis = container.xAxis
        
        guard let e = dataSet.entryForIndex(idx/stackSize) as? DataEntryBarChart else { return element }
        guard let dataProvider = dataProvider else { return element }
        
        let label = xAxis.valueFormatter?.stringForValue(e.x, axis: xAxis) ?? "\(e.x)"
        
        var elementValueText = dataSet.valueFormatter.stringForValue(
            e.y,
            entry: e,
            dataSetIndex: dataSetIndex,
            viewPortHandler: viewPortHandler)
        
        if dataSet.isStacked, let vals = e.yValues
        {
            let labelCount = min(dataSet.colors.count, stackSize)
            
            let stackLabel: String?
            if (!dataSet.stackLabels.isEmpty && labelCount > 0) {
                let labelIndex = idx % labelCount
                stackLabel = dataSet.stackLabels.indices.contains(labelIndex) ? dataSet.stackLabels[labelIndex] : nil
            } else {
                stackLabel = nil
            }
            
            let yValue = vals.isEmpty ? 0.0 : vals[idx % vals.count]
            
            elementValueText = dataSet.valueFormatter.stringForValue(
                yValue,
                entry: e,
                dataSetIndex: dataSetIndex,
                viewPortHandler: viewPortHandler)
            
            if let stackLabel = stackLabel {
                elementValueText = stackLabel + " \(elementValueText)"
            } else {
                elementValueText = "\(elementValueText)"
            }
        }
        
        let dataSetCount = dataProvider.barData?.dataSetCount ?? -1
        let doesContainMultipleDataSets = dataSetCount > 1
        
        element.accessibilityLabel = "\(doesContainMultipleDataSets ? (dataSet.label ?? "")  + ", " : "") \(label): \(elementValueText)"
        
        modifier(element)
        
        return element
    }
}

