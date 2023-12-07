//
//  ChartDataProvider.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc
public protocol DataProviderChart
{
    var chartXMin: Double { get }
    
    var chartXMax: Double { get }
    
    var chartYMin: Double { get }
    
    var chartYMax: Double { get }
    
    var maxHighlightDistance: CGFloat { get }
    
    var xRange: Double { get }
    
    var centerOffsets: CGPoint { get }
    
    var data: DataOfChart? { get }
    
    var maxVisibleCount: Int { get }
}

