//
//  BarChartDataProvider.swift
//  PUP001
//
//  Created by chuottp on 19/08/2023.
//

import Foundation
import CoreGraphics

@objc
public protocol DataProviderBarChart: DataProviderBarLineScatterCandleBubbleChart
{
    var barData: DataBarChart? { get }
    var isDrawBarShadowEnabled: Bool { get }
    var isDrawValueAboveBarEnabled: Bool { get }
    var isHighlightFullBarEnabled: Bool { get }
}
