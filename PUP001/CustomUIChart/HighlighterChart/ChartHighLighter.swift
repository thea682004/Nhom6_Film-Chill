//
//  ChartHighLighter.swift
//  PUP001
//
//  Created by chuottp on 19/08/2023.
//

import Foundation
import CoreGraphics

open class ChartsHighlighter : NSObject, HighlighterChart
{
    @objc open weak var chart: DataProviderChart?
    
    @objc public init(chart: DataProviderChart)
    {
        self.chart = chart
    }
    
    open func getHighlight(x: CGFloat, y: CGFloat) -> HighlightChart?
    {
        let xVal = Double(getValsForTouch(x: x, y: y).x)
        return getHighlight(xValue: xVal, x: x, y: y)
    }
    
    @objc open func getValsForTouch(x: CGFloat, y: CGFloat) -> CGPoint
    {
        guard let chart = self.chart as? DataProviderBarLineScatterCandleBubbleChart else { return .zero }
        return chart.getTransformer(forAxis: .left).valueForTouchPointBarChart(x: x, y: y)
    }
    
    @objc open func getHighlight(xValue xVal: Double, x: CGFloat, y: CGFloat) -> HighlightChart?
    {
        guard let chart = chart else { return nil }
        
        let closestValues = getHighlights(xValue: xVal, x: x, y: y)
        guard !closestValues.isEmpty else { return nil }
        
        let leftAxisMinDist = getMinimumDistance(closestValues: closestValues, y: y, axis: .left)
        let rightAxisMinDist = getMinimumDistance(closestValues: closestValues, y: y, axis: .right)
        
        let axis: YAxisChart.AxisDependency = leftAxisMinDist < rightAxisMinDist ? .left : .right
        
        let detail = closestSelectionDetailByPixel(closestValues: closestValues, x: x, y: y, axis: axis, minSelectionDistance: chart.maxHighlightDistance)
        
        return detail
    }
    
    @objc open func getHighlights(xValue: Double, x: CGFloat, y: CGFloat) -> [HighlightChart]
    {
        var vals = [HighlightChart]()
        
        guard let data = self.data else { return vals }
        for (i, set) in data.indexed() where set.isHighlightEnabled
        {
            vals.append(contentsOf: buildHighlights(dataSet: set, dataSetIndex: i, xValue: xValue, rounding: .closest))
        }
        
        return vals
    }
    
    internal func buildHighlights(
        dataSet set: ProtocolChartDataSet,
        dataSetIndex: Int,
        xValue: Double,
        rounding: ChartDataSetRounding) -> [HighlightChart]
    {
        guard let chart = self.chart as? DataProviderBarLineScatterCandleBubbleChart else { return [] }
        
        var entries = set.entriesForXValue(xValue)
        if entries.isEmpty, let closest = set.entryForXValue(xValue, closestToY: .nan, rounding: rounding)
        {
            entries = set.entriesForXValue(closest.x)
        }

        return entries.map { e in
            let px = chart.getTransformer(forAxis: set.axisDependency)
                .pixelForValuesBarChart(x: e.x, y: e.y)
            
            return HighlightChart(x: e.x, y: e.y, xPx: px.x, yPx: px.y, dataSetIndex: dataSetIndex, axis: set.axisDependency)
        }
    }

    internal func closestSelectionDetailByPixel(
        closestValues: [HighlightChart],
        x: CGFloat,
        y: CGFloat,
        axis: YAxisChart.AxisDependency?,
        minSelectionDistance: CGFloat) -> HighlightChart?
    {
        var distance = minSelectionDistance
        var closest: HighlightChart?
        
        for high in closestValues
        {
            if axis == nil || high.axis == axis
            {
                let cDistance = getDistance(x1: x, y1: y, x2: high.xPx, y2: high.yPx)

                if cDistance < distance
                {
                    closest = high
                    distance = cDistance
                }
            }
        }
        
        return closest
    }
    
    internal func getMinimumDistance(
        closestValues: [HighlightChart],
        y: CGFloat,
        axis: YAxisChart.AxisDependency
    ) -> CGFloat {
        var distance = CGFloat.greatestFiniteMagnitude
        
        for high in closestValues where high.axis == axis
        {
            let tempDistance = abs(getHighlightPos(high: high) - y)
            if tempDistance < distance
            {
                distance = tempDistance
            }
        }
        
        return distance
    }
    
    internal func getHighlightPos(high: HighlightChart) -> CGFloat
    {
        return high.yPx
    }
    
    internal func getDistance(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat
    {
        return hypot(x1 - x2, y1 - y2)
    }
    
    internal var data: DataOfChart?
    {
        return chart?.data
    }
}

