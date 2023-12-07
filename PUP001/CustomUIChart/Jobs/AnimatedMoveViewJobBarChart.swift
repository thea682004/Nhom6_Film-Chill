//
//  AnimatedMoveViewJob.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

open class AnimatedMoveViewJobBarChart: AnimatedViewPortJobBarChart
{
    internal override func animationUpdate()
    {
        var pt = CGPoint(
            x: xOrigin + (CGFloat(xValue) - xOrigin) * phase,
            y: yOrigin + (CGFloat(yValue) - yOrigin) * phase
        )
        
        transformer.pointValueToPixelBarChart(&pt)
        viewPortHandler.centerViewPort(pt: pt, chart: view)
    }
}

