//
//  MoveViewJob.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc(MoveChartViewJob)
open class MoveViewJobBarChart: ViewPortJobBarChart
{
    open override func doJob()
    {
        var pt = CGPoint(
            x: xValue,
            y: yValue
        )
        
        transformer.pointValueToPixelBarChart(&pt)
        viewPortHandler.centerViewPort(pt: pt, chart: view)
    }
}

