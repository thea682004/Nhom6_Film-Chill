//
//  TransformerHorizontalBarChart.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc(ChartTransformerHorizontalBarChart)
open class TransformerHorizontalBarChart: TransformerBarChart
{
    
    open override func prepareMatrixOffsetBarChart(inverted: Bool)
    {
        if !inverted
        {
            matrixOffset = CGAffineTransform(translationX: viewPortHandler.offsetLeft, y: viewPortHandler.chartHeight - viewPortHandler.offsetBottom)
        }
        else
        {
            matrixOffset = CGAffineTransform(scaleX: -1.0, y: 1.0)
                .translatedBy(x: -(viewPortHandler.chartWidth - viewPortHandler.offsetRight),
                              y: viewPortHandler.chartHeight - viewPortHandler.offsetBottom)
        }
    }
}


