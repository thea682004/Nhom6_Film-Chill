//
//  HorizontalBarChartView.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

open class HorizontalBarChartView: BarChartView
{
    internal override func initialize()
    {
        super.initialize()
        
        _leftAxisTransformer = TransformerHorizontalBarChart(viewPortHandler: viewPortHandler)
        _rightAxisTransformer = TransformerHorizontalBarChart(viewPortHandler: viewPortHandler)

        renderer = HorizontalBarChartRender(dataProvider: self, animator: chartAnimator, viewPortHandler: viewPortHandler)
        leftYAxisRenderer = YAxisRenderHorizontalBarChart(viewPortHandler: viewPortHandler, axis: leftAxis, transformer: _leftAxisTransformer)
        rightYAxisRenderer = YAxisRenderHorizontalBarChart(viewPortHandler: viewPortHandler, axis: rightAxis, transformer: _rightAxisTransformer)
        xAxisRenderer = XAxisRenderHorizontalBarChart(viewPortHandler: viewPortHandler, axis: xAxis, transformer: _leftAxisTransformer, chart: self)

        self.highlighter = HorizontalBarHighlighterChart(chart: self)
    }
    
    internal override func calculateLegendOffsets(offsetLeft: inout CGFloat, offsetTop: inout CGFloat, offsetRight: inout CGFloat, offsetBottom: inout CGFloat)
    {
        guard
            legend.isEnabled,
            !legend.drawInside
        else { return }
        
        switch legend.orientation
        {
        case .vertical:
            switch legend.horizontalAlignment
            {
            case .left:
                offsetLeft += min(legend.neededWidth, viewPortHandler.chartWidth * legend.maxSizePercent) + legend.xOffset
                
            case .right:
                offsetRight += min(legend.neededWidth, viewPortHandler.chartWidth * legend.maxSizePercent) + legend.xOffset
                
            case .center:
                
                switch legend.verticalAlignment
                {
                case .top:
                    offsetTop += min(legend.neededHeight, viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset
                    
                case .bottom:
                    offsetBottom += min(legend.neededHeight, viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset
                    
                default:
                    break
                }
            }
            
        case .horizontal:
            switch legend.verticalAlignment
            {
            case .top:
                offsetTop += min(legend.neededHeight, viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset
                
                if leftAxis.isEnabled && leftAxis.isDrawLabelsEnabled
                {
                    offsetTop += leftAxis.getRequiredHeightSpace()
                }
                
            case .bottom:
                offsetBottom += min(legend.neededHeight, viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset

                if rightAxis.isEnabled && rightAxis.isDrawLabelsEnabled
                {
                    offsetBottom += rightAxis.getRequiredHeightSpace()
                }
            default:
                break
            }
        }
    }
    
    internal override func calculateOffsets()
    {
        var offsetLeft: CGFloat = 0.0,
        offsetRight: CGFloat = 0.0,
        offsetTop: CGFloat = 0.0,
        offsetBottom: CGFloat = 0.0
        
        calculateLegendOffsets(offsetLeft: &offsetLeft,
                               offsetTop: &offsetTop,
                               offsetRight: &offsetRight,
                               offsetBottom: &offsetBottom)
        
        if leftAxis.needsOffset
        {
            offsetTop += leftAxis.getRequiredHeightSpace()
        }
        
        if rightAxis.needsOffset
        {
            offsetBottom += rightAxis.getRequiredHeightSpace()
        }
        
        let xlabelwidth = xAxis.labelRotatedWidth
        
        if xAxis.isEnabled
        {
            if xAxis.labelPosition == .bottom
            {
                offsetLeft += xlabelwidth
            }
            else if xAxis.labelPosition == .top
            {
                offsetRight += xlabelwidth
            }
            else if xAxis.labelPosition == .bothSided
            {
                offsetLeft += xlabelwidth
                offsetRight += xlabelwidth
            }
        }
        
        offsetTop += self.extraTopOffset
        offsetRight += self.extraRightOffset
        offsetBottom += self.extraBottomOffset
        offsetLeft += self.extraLeftOffset

        viewPortHandler.restrainViewPort(
            offsetLeft: max(self.minOffset, offsetLeft),
            offsetTop: max(self.minOffset, offsetTop),
            offsetRight: max(self.minOffset, offsetRight),
            offsetBottom: max(self.minOffset, offsetBottom))
        
        prepareOffsetMatrix()
        prepareValuePxMatrix()
    }
    
    internal override func prepareValuePxMatrix()
    {
        _rightAxisTransformer.prepareMatrixValuePx(chartXMin: rightAxis._axisMinimum, deltaX: CGFloat(rightAxis.axisRange), deltaY: CGFloat(xAxis.axisRange), chartYMin: xAxis._axisMinimum)
        _leftAxisTransformer.prepareMatrixValuePx(chartXMin: leftAxis._axisMinimum, deltaX: CGFloat(leftAxis.axisRange), deltaY: CGFloat(xAxis.axisRange), chartYMin: xAxis._axisMinimum)
    }
    
    open override func getMarkerPosition(highlight: HighlightChart) -> CGPoint
    {
        return CGPoint(x: highlight.drawY, y: highlight.drawX)
    }
    
    open override func getBarBounds(entry e: DataEntryBarChart) -> CGRect
    {
        guard
            let data = data as? DataBarChart,
            let set = data.getDataSetForEntry(e) as? ProtocolBarChartDataSet
            else { return .null }
        
        let y = e.y
        let x = e.x
        
        let barWidth = data.barWidth
        
        let top = x - 0.5 + barWidth / 2.0
        let bottom = x + 0.5 - barWidth / 2.0
        let left = y >= 0.0 ? y : 0.0
        let right = y <= 0.0 ? y : 0.0
        
        var bounds = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        
        getTransformer(forAxis: set.axisDependency).rectValueToPixelBarChart(&bounds)
        
        return bounds
    }
    
    open override func getPosition(entry e: DataEntryChart, axis: YAxisChart.AxisDependency) -> CGPoint
    {
        var vals = CGPoint(x: CGFloat(e.y), y: CGFloat(e.x))
        
        getTransformer(forAxis: axis).pointValueToPixelBarChart(&vals)
        
        return vals
    }

    open override func getHighlightByTouchPoint(_ pt: CGPoint) -> HighlightChart?
    {
        if data === nil
        {
            Swift.print("Can't select by touch. No data set.", terminator: "\n")
            return nil
        }
        
        return self.highlighter?.getHighlight(x: pt.y, y: pt.x)
    }
    
    open override var lowestVisibleX: Double
    {
        var pt = CGPoint(
            x: viewPortHandler.contentLeft,
            y: viewPortHandler.contentBottom)
        
        getTransformer(forAxis: .left).pixelToValuesBarChart(&pt)
        
        return max(xAxis._axisMinimum, Double(pt.y))
    }
    
    open override var highestVisibleX: Double
    {
        var pt = CGPoint(
            x: viewPortHandler.contentLeft,
            y: viewPortHandler.contentTop)
        
        getTransformer(forAxis: .left).pixelToValuesBarChart(&pt)
        
        return min(xAxis._axisMaximum, Double(pt.y))
    }
        
    open override func setVisibleXRangeMaximum(_ maxXRange: Double)
    {
        let xScale = xAxis.axisRange / maxXRange
        viewPortHandler.setMinimumScaleY(CGFloat(xScale))
    }
    
    open override func setVisibleXRangeMinimum(_ minXRange: Double)
    {
        let xScale = xAxis.axisRange / minXRange
        viewPortHandler.setMaximumScaleY(CGFloat(xScale))
    }
    
    open override func setVisibleXRange(minXRange: Double, maxXRange: Double)
    {
        let minScale = xAxis.axisRange / minXRange
        let maxScale = xAxis.axisRange / maxXRange
        viewPortHandler.setMinMaxScaleY(minScaleY: CGFloat(minScale), maxScaleY: CGFloat(maxScale))
    }
    
    open override func setVisibleYRangeMaximum(_ maxYRange: Double, axis: YAxisChart.AxisDependency)
    {
        let yScale = getAxisRange(axis: axis) / maxYRange
        viewPortHandler.setMinimumScaleX(CGFloat(yScale))
    }
    
    open override func setVisibleYRangeMinimum(_ minYRange: Double, axis: YAxisChart.AxisDependency)
    {
        let yScale = getAxisRange(axis: axis) / minYRange
        viewPortHandler.setMaximumScaleX(CGFloat(yScale))
    }
    
    open override func setVisibleYRange(minYRange: Double, maxYRange: Double, axis: YAxisChart.AxisDependency)
    {
        let minScale = getAxisRange(axis: axis) / minYRange
        let maxScale = getAxisRange(axis: axis) / maxYRange
        viewPortHandler.setMinMaxScaleX(minScaleX: CGFloat(minScale), maxScaleX: CGFloat(maxScale))
    }
}

