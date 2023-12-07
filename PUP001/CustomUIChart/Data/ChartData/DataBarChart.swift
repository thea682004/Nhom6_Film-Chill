//
//  BarChartData.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

open class DataBarChart: DataOfBarLineScatterCandleBubbleChart
{
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

    @objc open var barWidth = Double(0.85)
    
    @objc open func groupBars(fromX: Double, groupSpace: Double, barSpace: Double)
    {
        guard !isEmpty else {
            print("BarData needs to hold at least 2 BarDataSets to allow grouping.", terminator: "\n")
            return
        }

        let max = maxEntryCountSet
        let maxEntryCount = max?.entryCount ?? 0
        
        let groupSpaceWidthHalf = groupSpace / 2.0
        let barSpaceHalf = barSpace / 2.0
        let barWidthHalf = self.barWidth / 2.0
        
        var fromX = fromX
        
        let interval = groupWidth(groupSpace: groupSpace, barSpace: barSpace)

        for i in 0..<maxEntryCount
        {
            let start = fromX
            fromX += groupSpaceWidthHalf
            
            (_dataSets as! [ProtocolBarChartDataSet]).forEach { set in
                fromX += barSpaceHalf
                fromX += barWidthHalf
                
                if i < set.entryCount
                {
                    if let entry = set.entryForIndex(i)
                    {
                        entry.x = fromX
                    }
                }
                
                fromX += barWidthHalf
                fromX += barSpaceHalf
            }
            
            fromX += groupSpaceWidthHalf
            let end = fromX
            let innerInterval = end - start
            let diff = interval - innerInterval
            
            if diff > 0 || diff < 0
            {
                fromX += diff
            }
        }
        
        notifyDataChanged()
    }
    
    @objc open func groupWidth(groupSpace: Double, barSpace: Double) -> Double
    {
        return Double(count) * (self.barWidth + barSpace) + groupSpace
    }
}

