//
//  BarLineScatterCandleBubbleChartDataProvider.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc
public protocol DataProviderBarLineScatterCandleBubbleChart: DataProviderChart
{
    func getTransformer(forAxis: YAxisChart.AxisDependency) -> TransformerBarChart
    func isInverted(axis: YAxisChart.AxisDependency) -> Bool
    
    var lowestVisibleX: Double { get }
    var highestVisibleX: Double { get }
}

