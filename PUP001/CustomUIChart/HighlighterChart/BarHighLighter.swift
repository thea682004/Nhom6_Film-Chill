//
//  BarHighLighter.swift
//  PUP001
//
//  Created by chuottp on 19/08/2023.
//

import Foundation
import CoreGraphics

@objc(BarChartHighlighter)
open class BarChartHighlighter: ChartsHighlighter
{
    open override func getHighlight(x: CGFloat, y: CGFloat) -> HighlightChart?
    {
        guard
            let barData = (self.chart as? DataProviderBarChart)?.barData,
            let high = super.getHighlight(x: x, y: y)
            else { return nil }
        
        let pos = getValsForTouch(x: x, y: y)

        if let set = barData[high.dataSetIndex] as? ProtocolBarChartDataSet,
            set.isStacked
        {
            return getStackedHighlight(high: high,
                                       set: set,
                                       xValue: Double(pos.x),
                                       yValue: Double(pos.y))
        }
        else
        {
            return high
        }
    }
    
    internal override func getDistance(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat
    {
        return abs(x1 - x2)
    }
    
    internal override var data: DataOfChart?
    {
        return (chart as? DataProviderBarChart)?.barData
    }
    
    @objc open func getStackedHighlight(high: HighlightChart,
                                  set: ProtocolBarChartDataSet,
                                  xValue: Double,
                                  yValue: Double) -> HighlightChart?
    {
        guard
            let chart = self.chart as? DataProviderBarLineScatterCandleBubbleChart,
            let entry = set.entryForXValue(xValue, closestToY: yValue) as? DataEntryBarChart
            else { return nil }
        
        if entry.yValues == nil
        {
            return high
        }
        
        guard
            let ranges = entry.ranges,
            !ranges.isEmpty
            else { return nil }

        let stackIndex = getClosestStackIndex(ranges: ranges, value: yValue)
        let pixel = chart
            .getTransformer(forAxis: set.axisDependency)
            .pixelForValuesBarChart(x: high.x, y: ranges[stackIndex].to)

        return HighlightChart(x: entry.x,
                         y: entry.y,
                         xPx: pixel.x,
                         yPx: pixel.y,
                         dataSetIndex: high.dataSetIndex,
                         stackIndex: stackIndex,
                         axis: high.axis)
    }
    
    @objc open func getClosestStackIndex(ranges: [RangeChart]?, value: Double) -> Int
    {
        guard let ranges = ranges else { return 0 }
        
        if let stackIndex = ranges.firstIndex(where: { $0.contains(value) }) {
            return stackIndex
        } else {
            let length = max(ranges.endIndex - 1, 0)
            return (value > ranges[length].to) ? length : 0
        }
    }
}

