//
//  DataRenderer.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc(ChartDataRenderer)
public protocol DataRenderBarChart: RenderBarChart
{
    var accessibleChartElements: [NSUIAccessibilityElement] { get }
    
    var animator: AnimatorChart { get }
    
    func drawData(context: CGContext)
    
    func drawValues(context: CGContext)
    
    func drawExtras(context: CGContext)
    
    func drawHighlighted(context: CGContext, indices: [HighlightChart])
    
    func initBuffers()
    
    func isDrawingValuesAllowed(dataProvider: DataProviderChart?) -> Bool
    
    func createAccessibleHeader(usingChart chart: ChartViewBase,
                                andData data: DataOfChart,
                                withDefaultDescription defaultDescription: String) -> NSUIAccessibilityElement
}

internal struct AccessibleHeader {
    static func create(usingChart chart: ChartViewBase,
                       andData data: DataOfChart,
                       withDefaultDescription defaultDescription: String = "Chart") -> NSUIAccessibilityElement
    {
        let chartDescriptionText = chart.chartDescription.text ?? defaultDescription
        let dataSetDescriptions = data.map { $0.label ?? "" }
        let dataSetDescriptionText = dataSetDescriptions.joined(separator: ", ")
        
        let element = NSUIAccessibilityElement(accessibilityContainer: chart)
        element.accessibilityLabel = chartDescriptionText + ". \(data.count) dataset\(data.count == 1 ? "" : "s"). \(dataSetDescriptionText)"
        element.accessibilityFrame = chart.bounds
        element.checkIsHeader = true
        
        return element
    }
}

