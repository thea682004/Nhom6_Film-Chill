//
//  ValueFormatter.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

@objc(ChartValueFormatter)
public protocol FormatterValue: AnyObject
{
    
    func stringForValue(_ value: Double,
                        entry: DataEntryChart,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String
}

