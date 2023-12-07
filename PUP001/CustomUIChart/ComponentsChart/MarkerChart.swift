//
//  Marker.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc(ChartMarker)
public protocol MarkerChart: AnyObject
{
    var offset: CGPoint { get }
    func offsetForDrawing(atPoint: CGPoint) -> CGPoint
    
    func refreshContent(entry: DataEntryChart, highlight: HighlightChart)
    
    func draw(context: CGContext, point: CGPoint)
}

