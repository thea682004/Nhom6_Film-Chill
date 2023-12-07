//
//  AxisRenderer.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics


public protocol AxisRenderBarChart: RenderBarChart {
    
    associatedtype Axis: AxisBaseBarChart
    
    var axis: Axis { get }
    var transformer: TransformerBarChart? { get }
    
    func renderAxisLabels(context: CGContext)
    
    func renderGridLines(context: CGContext)
    
    func renderAxisLine(context: CGContext)
    
    func renderLimitLines(context: CGContext)
    
    func computeAxis(min: Double, max: Double, inverted: Bool)
    
    func computeAxisValues(min: Double, max: Double)
}

