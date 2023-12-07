//
//  AxisValueFormatter.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

@objc(ChartAxisValueFormatter)
public protocol FormatterAxisValue: AnyObject
{
    func stringForValue(_ value: Double,
                        axis: AxisBaseBarChart?) -> String
    
}

