//
//  HorizontalBarHighlighter.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc(HorizontalBarChartHighlighter)
open class HorizontalBarHighlighterChart: BarChartHighlighter
{
    open override func getHighlight(x: CGFloat, y: CGFloat) -> HighlightChart?
    {
        guard let barData = self.chart?.data as? DataBarChart else { return nil }

        let pos = getValsForTouch(x: y, y: x)
        guard let high = getHighlight(xValue: Double(pos.y), x: y, y: x) else { return nil }

        if let set = barData[high.dataSetIndex] as? ProtocolBarChartDataSet,
            set.isStacked
        {
            return getStackedHighlight(high: high,
                                       set: set,
                                       xValue: Double(pos.y),
                                       yValue: Double(pos.x))
        }

        return high
    }
    
    internal override func buildHighlights(
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
                .pixelForValuesBarChart(x: e.y, y: e.x)
            return HighlightChart(x: e.x, y: e.y, xPx: px.x, yPx: px.y, dataSetIndex: dataSetIndex, axis: set.axisDependency)
        }
    }
    
    internal override func getDistance(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat
    {
        return abs(y1 - y2)
    }
}

