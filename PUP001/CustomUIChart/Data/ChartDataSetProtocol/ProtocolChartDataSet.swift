//
//  ChartDataSetProtocol.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc
public protocol ProtocolChartDataSet
{
    
    func notifyDataSetChanged()
    
    func calcMinMax()
    
    func calcMinMaxY(fromX: Double, toX: Double)
    
    var yMin: Double { get }
    
    var yMax: Double { get }
    
    var xMin: Double { get }
    
    var xMax: Double { get }
    
    var entryCount: Int { get }
    
    func entryForIndex(_ i: Int) -> DataEntryChart?
    
    func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding) -> DataEntryChart?
    
    func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double) -> DataEntryChart?
    
    func entriesForXValue(_ xValue: Double) -> [DataEntryChart]
    
    func entryIndex(
        x xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding) -> Int
    
    func entryIndex(entry e: DataEntryChart) -> Int
    
    func addEntry(_ e: DataEntryChart) -> Bool
    
    func addEntryOrdered(_ e: DataEntryChart) -> Bool
    
    func removeEntry(_ entry: DataEntryChart) -> Bool
    
    func removeEntry(index: Int) -> Bool
    
    func removeEntry(x: Double) -> Bool
    
    func removeFirst() -> Bool
 
    func removeLast() -> Bool
    
    func contains(_ e: DataEntryChart) -> Bool

    func clear()
    
    var label: String? { get }
    
    var axisDependency: YAxisChart.AxisDependency { get }
    
    var valueColors: [NSUIColor] { get }
    
    var colors: [NSUIColor] { get }
    
    func color(atIndex: Int) -> NSUIColor
    
    func resetColors()
    
    func addColor(_ color: NSUIColor)
    
    func setColor(_ color: NSUIColor)
    
    var highlightEnabled: Bool { get set }
    
    var isHighlightEnabled: Bool { get }
    
    var valueFormatter: FormatterValue { get set }
    
    var valueTextColor: NSUIColor { get set }
    
    func valueTextColorAt(_ index: Int) -> NSUIColor
    
    var valueFont: NSUIFont { get set }
    
    var valueLabelAngle: CGFloat { get set }
    
    var form: LegendChart.Form { get }
    
    var formSize: CGFloat { get }
    
    var formLineWidth: CGFloat { get }
    
    var formLineDashPhase: CGFloat { get }

    var formLineDashLengths: [CGFloat]? { get }
  
    var drawValuesEnabled: Bool { get set }
    
    var isDrawValuesEnabled: Bool { get }
    
    var drawIconsEnabled: Bool { get set }
    
    var isDrawIconsEnabled: Bool { get }
    
    var iconsOffset: CGPoint { get set }
    
    var visible: Bool { get set }
    
    var isVisible: Bool { get }
}

