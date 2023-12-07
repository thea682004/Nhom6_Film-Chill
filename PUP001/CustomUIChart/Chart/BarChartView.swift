//
//  BarChartView.swift
//  PUP001
//
//  Created by chuottp on 19/08/2023.
//

import Foundation
import CoreGraphics

open class BarChartView: BarLineChartViewBase, DataProviderBarChart
{
   
    private var _drawValueAboveBarEnabled = true

    
    private var _drawBarShadowEnabled = false
    
    internal override func initialize()
    {
        super.initialize()
        
        renderer = BarChartRender(dataProvider: self, animator: chartAnimator, viewPortHandler: viewPortHandler)
        
        self.highlighter = BarChartHighlighter(chart: self)
        
        self.xAxis.spaceMin = 0.5
        self.xAxis.spaceMax = 0.5
    }
    
    internal override func calcMinMax()
    {
        guard let data = self.data as? DataBarChart
            else { return }
        
        if fitBars
        {
            xAxis.calculate(
                min: data.xMin - data.barWidth / 2.0,
                max: data.xMax + data.barWidth / 2.0)
        }
        else
        {
            xAxis.calculate(min: data.xMin, max: data.xMax)
        }
        
        
        leftAxis.calculate(
            min: data.getYMin(axis: .left),
            max: data.getYMax(axis: .left))
        rightAxis.calculate(
            min: data.getYMin(axis: .right),
            max: data.getYMax(axis: .right))
    }
    
    open override func getHighlightByTouchPoint(_ pt: CGPoint) -> HighlightChart?
    {
        if data === nil
        {
            Swift.print("Can't select by touch. No data set.")
            return nil
        }
        
        guard let h = self.highlighter?.getHighlight(x: pt.x, y: pt.y)
            else { return nil }
        
        if !isHighlightFullBarEnabled { return h }
        
        return HighlightChart(
            x: h.x, y: h.y,
            xPx: h.xPx, yPx: h.yPx,
            dataIndex: h.dataIndex,
            dataSetIndex: h.dataSetIndex,
            stackIndex: -1,
            axis: h.axis)
    }
        
    
    @objc open func getBarBounds(entry e: DataEntryBarChart) -> CGRect
    {
        guard let
            data = data as? DataBarChart,
            let set = data.getDataSetForEntry(e) as? ProtocolBarChartDataSet
            else { return .null }
        
        let y = e.y
        let x = e.x
        
        let barWidth = data.barWidth
        
        let left = x - barWidth / 2.0
        let right = x + barWidth / 2.0
        let top = y >= 0.0 ? y : 0.0
        let bottom = y <= 0.0 ? y : 0.0
        
        var bounds = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        
        getTransformer(forAxis: set.axisDependency).rectValueToPixelBarChart(&bounds)
        
        return bounds
    }
    
    @objc open func groupBars(fromX: Double, groupSpace: Double, barSpace: Double)
    {
        guard let barData = self.barData
            else
        {
            Swift.print("You need to set data for the chart before grouping bars.", terminator: "\n")
            return
        }
        
        barData.groupBars(fromX: fromX, groupSpace: groupSpace, barSpace: barSpace)
        notifyDataSetChanged()
    }
    
    @objc open func highlightValue(x: Double, dataSetIndex: Int, stackIndex: Int)
    {
        highlightValue(HighlightChart(x: x, dataSetIndex: dataSetIndex, stackIndex: stackIndex))
    }

    @objc open var drawValueAboveBarEnabled: Bool
    {
        get { return _drawValueAboveBarEnabled }
        set
        {
            _drawValueAboveBarEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    @objc open var drawBarShadowEnabled: Bool
    {
        get { return _drawBarShadowEnabled }
        set
        {
            _drawBarShadowEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    @objc open var fitBars = false
    
    @objc open var highlightFullBarEnabled: Bool = false
    
    open var isHighlightFullBarEnabled: Bool { return highlightFullBarEnabled }
        
    open var barData: DataBarChart? { return data as? DataBarChart }
    
    open var isDrawValueAboveBarEnabled: Bool { return drawValueAboveBarEnabled }
    
    open var isDrawBarShadowEnabled: Bool { return drawBarShadowEnabled }
}

