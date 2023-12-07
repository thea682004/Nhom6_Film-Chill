//
//  CombinedChartData.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

open class DataOfCombinedChart: DataOfBarLineScatterCandleBubbleChart
{
    private var _barData: DataBarChart!
    
    public required init()
    {
        super.init()
    }
    
    public override init(dataSets: [ProtocolChartDataSet])
    {
        super.init(dataSets: dataSets)
    }

    public required init(arrayLiteral elements: ProtocolChartDataSet...)
    {
        super.init(dataSets: elements)
    }
    
    @objc open var barData: DataBarChart!
    {
        get
        {
            return _barData
        }
        set
        {
            _barData = newValue
            notifyDataChanged()
        }
    }
    
    open override func calcMinMax()
    {
        _dataSets.removeAll()
        
        yMax = -Double.greatestFiniteMagnitude
        yMin = Double.greatestFiniteMagnitude
        xMax = -Double.greatestFiniteMagnitude
        xMin = Double.greatestFiniteMagnitude
        
        leftAxisMax = -Double.greatestFiniteMagnitude
        leftAxisMin = Double.greatestFiniteMagnitude
        rightAxisMax = -Double.greatestFiniteMagnitude
        rightAxisMin = Double.greatestFiniteMagnitude
        
        let allData = self.allData
        
        for data in allData
        {
            data.calcMinMax()
            
            _dataSets.append(contentsOf: data)
            
            if data.yMax > yMax
            {
                yMax = data.yMax
            }
            
            if data.yMin < yMin
            {
                yMin = data.yMin
            }
            
            if data.xMax > xMax
            {
                xMax = data.xMax
            }
            
            if data.xMin < xMin
            {
                xMin = data.xMin
            }

            for set in data
            {
                if set.axisDependency == .left
                {
                    if set.yMax > leftAxisMax
                    {
                        leftAxisMax = set.yMax
                    }
                    if set.yMin < leftAxisMin
                    {
                        leftAxisMin = set.yMin
                    }
                }
                else
                {
                    if set.yMax > rightAxisMax
                    {
                        rightAxisMax = set.yMax
                    }
                    if set.yMin < rightAxisMin
                    {
                        rightAxisMin = set.yMin
                    }
                }
            }
        }
    }
    
    @objc open var allData: [DataOfChart]
    {
        var data = [DataOfChart]()
        
        if barData !== nil
        {
            data.append(barData)
        }
        return data
    }
    
    @objc open func dataByIndex(_ index: Int) -> DataOfChart
    {
        return allData[index]
    }
    
    open func dataIndex(_ data: DataOfChart) -> Int?
    {
        return allData.firstIndex(of: data)
    }
    
    open override func removeDataSet(_ dataSet: ProtocolChartDataSet) -> Element?
    {
        for data in allData
        {
            if let e = data.removeDataSet(dataSet)
            {
                return e
            }
        }
        
        return nil
    }

    open override func removeEntry(_ entry: DataEntryChart, dataSetIndex: Int) -> Bool
    {
        print("removeEntry(entry, dataSetIndex) not supported for CombinedData", terminator: "\n")
        return false
    }
    
    open override func removeEntry(xValue: Double, dataSetIndex: Int) -> Bool
    {
        print("removeEntry(xValue, dataSetIndex) not supported for CombinedData", terminator: "\n")
        return false
    }
    
    open override func notifyDataChanged()
    {
        _barData?.notifyDataChanged()
        super.notifyDataChanged()
    }
    
    @objc override open func entry(for highlight: HighlightChart) -> DataEntryChart?
    {
        getDataSetByHighlight(highlight)?
            .entriesForXValue(highlight.x)
            .first { $0.y == highlight.y || highlight.y.isNaN }
    }
    
    @objc open func getDataSetByHighlight(_ highlight: HighlightChart) -> ProtocolChartDataSet!
    {
        guard allData.indices.contains(highlight.dataIndex) else
        {
            return nil
        }

        let data = dataByIndex(highlight.dataIndex)

        guard data.indices.contains(highlight.dataSetIndex) else
        {
            return nil
        }

        return data[highlight.dataSetIndex]
    }

    public override func append(_ newElement: DataOfChart.Element) {
        fatalError("append(_:) not supported for CombinedData")
    }

    public override func remove(at i: Int) -> ProtocolChartDataSet {
        fatalError("remove(at:) not supported for CombinedData")
    }
}

