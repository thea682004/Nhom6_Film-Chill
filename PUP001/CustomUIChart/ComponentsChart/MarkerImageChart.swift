//
//  MarkerImage.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc(ChartMarkerImage)
open class MarkerImageChart: NSObject, MarkerChart
{
    @objc open var image: NSUIImage?
    
    open var offset: CGPoint = CGPoint()
    
    @objc open weak var chartView: ChartViewBase?
    
    @objc open var size: CGSize = CGSize()
    
    public override init()
    {
        super.init()
    }
    
    open func offsetForDrawing(atPoint point: CGPoint) -> CGPoint
    {
        var offset = self.offset
        
        let chart = self.chartView
        
        var size = self.size
        
        if size.width == 0.0 && image != nil
        {
            size.width = image?.size.width ?? 0.0
        }
        if size.height == 0.0 && image != nil
        {
            size.height = image?.size.height ?? 0.0
        }
        
        let width = size.width
        let height = size.height
        
        if point.x + offset.x < 0.0
        {
            offset.x = -point.x
        }
        else if chart != nil && point.x + width + offset.x > chart!.bounds.size.width
        {
            offset.x = chart!.bounds.size.width - point.x - width
        }
        
        if point.y + offset.y < 0
        {
            offset.y = -point.y
        }
        else if chart != nil && point.y + height + offset.y > chart!.bounds.size.height
        {
            offset.y = chart!.bounds.size.height - point.y - height
        }
        
        return offset
    }
    
    open func refreshContent(entry: DataEntryChart, highlight: HighlightChart)
    {
    }
    
    open func draw(context: CGContext, point: CGPoint)
    {
        guard let image = image else { return }

        let offset = offsetForDrawing(atPoint: point)
        
        var size = self.size
        
        if size.width == 0.0
        {
            size.width = image.size.width
        }
        if size.height == 0.0
        {
            size.height = image.size.height
        }
        
        let rect = CGRect(
            x: point.x + offset.x,
            y: point.y + offset.y,
            width: size.width,
            height: size.height)
        
        NSUIGraphicsPushContext(context)
        image.draw(in: rect)
        NSUIGraphicsPopContext()
    }
}

