//
//  ChartBaseDataSet.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics


open class SetBaseChartData: NSObject, ProtocolChartDataSet, NSCopying
{
    public required override init()
    {
        super.init()
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        valueColors.append(.labelOrBlack)
    }
    
    @objc public init(label: String)
    {
        super.init()
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        valueColors.append(.labelOrBlack)
        
        self.label = label
    }

    open func notifyDataSetChanged()
    {
        calcMinMax()
    }
    
    open func calcMinMax()
    {
        fatalError("calcMinMax is not implemented in ChartBaseDataSet")
    }
    
    open func calcMinMaxY(fromX: Double, toX: Double)
    {
        fatalError("calcMinMaxY(fromX:, toX:) is not implemented in ChartBaseDataSet")
    }
    
    open var yMin: Double
    {
        fatalError("yMin is not implemented in ChartBaseDataSet")
    }
    
    open var yMax: Double
    {
        fatalError("yMax is not implemented in ChartBaseDataSet")
    }
    
    open var xMin: Double
    {
        fatalError("xMin is not implemented in ChartBaseDataSet")
    }
    
    open var xMax: Double
    {
        fatalError("xMax is not implemented in ChartBaseDataSet")
    }
    
    open var entryCount: Int
    {
        fatalError("entryCount is not implemented in ChartBaseDataSet")
    }
        
    open func entryForIndex(_ i: Int) -> DataEntryChart?
    {
        fatalError("entryForIndex is not implemented in ChartBaseDataSet")
    }
    
    open func entryForXValue(
        _ x: Double,
        closestToY y: Double,
        rounding: ChartDataSetRounding) -> DataEntryChart?
    {
        fatalError("entryForXValue(x, closestToY, rounding) is not implemented in ChartBaseDataSet")
    }
    
    open func entryForXValue(
        _ x: Double,
        closestToY y: Double) -> DataEntryChart?
    {
        fatalError("entryForXValue(x, closestToY) is not implemented in ChartBaseDataSet")
    }
    
    open func entriesForXValue(_ x: Double) -> [DataEntryChart]
    {
        fatalError("entriesForXValue is not implemented in ChartBaseDataSet")
    }
    
    open func entryIndex(
        x xValue: Double,
        closestToY y: Double,
        rounding: ChartDataSetRounding) -> Int
    {
        fatalError("entryIndex(x, closestToY, rounding) is not implemented in ChartBaseDataSet")
    }
    
    open func entryIndex(entry e: DataEntryChart) -> Int
    {
        fatalError("entryIndex(entry) is not implemented in ChartBaseDataSet")
    }
    
    @discardableResult open func addEntry(_ e: DataEntryChart) -> Bool
    {
        fatalError("addEntry is not implemented in ChartBaseDataSet")
    }
    
    @discardableResult open func addEntryOrdered(_ e: DataEntryChart) -> Bool
    {
        fatalError("addEntryOrdered is not implemented in ChartBaseDataSet")
    }
    
    @discardableResult open func removeEntry(_ entry: DataEntryChart) -> Bool
    {
        fatalError("removeEntry is not implemented in ChartBaseDataSet")
    }
    
    @discardableResult open func removeEntry(index: Int) -> Bool
    {
        if let entry = entryForIndex(index)
        {
            return removeEntry(entry)
        }
        return false
    }
    
    @discardableResult open func removeEntry(x: Double) -> Bool
    {
        if let entry = entryForXValue(x, closestToY: Double.nan)
        {
            return removeEntry(entry)
        }
        return false
    }
    
    @discardableResult open func removeFirst() -> Bool
    {
        if entryCount > 0
        {
            if let entry = entryForIndex(0)
            {
                return removeEntry(entry)
            }
        }
        return false
    }
    
    @discardableResult open func removeLast() -> Bool
    {
        if entryCount > 0
        {
            if let entry = entryForIndex(entryCount - 1)
            {
                return removeEntry(entry)
            }
        }
        return false
    }
    
    open func contains(_ e: DataEntryChart) -> Bool
    {
        fatalError("removeEntry is not implemented in ChartBaseDataSet")
    }
    
    open func clear()
    {
        fatalError("clear is not implemented in ChartBaseDataSet")
    }
    
    open var colors = [NSUIColor]()
    
    open var valueColors = [NSUIColor]()

    open var label: String? = "DataSet"
    
    open var axisDependency = YAxisChart.AxisDependency.left
    
    open func color(atIndex index: Int) -> NSUIColor
    {
        var index = index
        if index < 0
        {
            index = 0
        }
        return colors[index % colors.count]
    }
    
    open func resetColors()
    {
        colors.removeAll(keepingCapacity: false)
    }
    
    open func addColor(_ color: NSUIColor)
    {
        colors.append(color)
    }
    
    open func setColor(_ color: NSUIColor)
    {
        colors.removeAll(keepingCapacity: false)
        colors.append(color)
    }
    
    @objc open func setColor(_ color: NSUIColor, alpha: CGFloat)
    {
        setColor(color.withAlphaComponent(alpha))
    }
    
    @objc open func setColors(_ colors: [NSUIColor], alpha: CGFloat)
    {
        self.colors = colors.map { $0.withAlphaComponent(alpha) }
    }
    
    open func setColors(_ colors: NSUIColor...)
    {
        self.colors = colors
    }
    
    open var highlightEnabled = true
    
    open var isHighlightEnabled: Bool { return highlightEnabled }
        
    open lazy var valueFormatter: FormatterValue = FormatterDefaultValue()
    
    open var valueTextColor: NSUIColor
    {
        get
        {
            return valueColors[0]
        }
        set
        {
            valueColors.removeAll(keepingCapacity: false)
            valueColors.append(newValue)
        }
    }
        open func valueTextColorAt(_ index: Int) -> NSUIColor
    {
        var index = index
        if index < 0
        {
            index = 0
        }
        return valueColors[index % valueColors.count]
    }
    
    open var valueFont: NSUIFont = NSUIFont.systemFont(ofSize: 7.0)
    
    open var valueLabelAngle: CGFloat = CGFloat(0.0)
    
    open var form = LegendChart.Form.default
    
    open var formSize: CGFloat = CGFloat.nan
    
    open var formLineWidth: CGFloat = CGFloat.nan

    open var formLineDashPhase: CGFloat = 0.0

    open var formLineDashLengths: [CGFloat]? = nil
    
    open var drawValuesEnabled = true
    
    open var isDrawValuesEnabled: Bool
    {
        return drawValuesEnabled
    }

    open var drawIconsEnabled = true
    
    open var isDrawIconsEnabled: Bool
    {
        return drawIconsEnabled
    }
    
    open var iconsOffset = CGPoint(x: 0, y: 0)
    
    open var visible = true
    
    open var isVisible: Bool
    {
        return visible
    }
        
    open override var description: String
    {
        return String(format: "%@, label: %@, %i entries", arguments: [NSStringFromClass(type(of: self)), self.label ?? "", self.entryCount])
    }
    
    open override var debugDescription: String
    {
        return (0..<entryCount).reduce(description + ":") {
            "\($0)\n\(self.entryForIndex($1)?.description ?? "")"
        }
    }
    
    open func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = type(of: self).init()
        
        copy.colors = colors
        copy.valueColors = valueColors
        copy.label = label
        copy.axisDependency = axisDependency
        copy.highlightEnabled = highlightEnabled
        copy.valueFormatter = valueFormatter
        copy.valueFont = valueFont
        copy.form = form
        copy.formSize = formSize
        copy.formLineWidth = formLineWidth
        copy.formLineDashPhase = formLineDashPhase
        copy.formLineDashLengths = formLineDashLengths
        copy.drawValuesEnabled = drawValuesEnabled
        copy.drawIconsEnabled = drawIconsEnabled
        copy.iconsOffset = iconsOffset
        copy.visible = visible
        
        return copy
    }
}

