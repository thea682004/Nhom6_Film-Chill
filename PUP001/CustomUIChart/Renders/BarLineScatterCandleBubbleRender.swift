//
//  BarLineScatterCandleBubbleRenderer.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc(BarLineScatterCandleBubbleChartRenderer)
open class BarLineScatterCandleBubbleRender: NSObject, DataRenderBarChart
{
    public let viewPortHandler: ViewPortHandler
    
    public final var accessibleChartElements: [NSUIAccessibilityElement] = []
    
    public let animator: AnimatorChart
    
    internal var _xBounds = XBounds()
    
    public init(animator: AnimatorChart, viewPortHandler: ViewPortHandler)
    {
        self.viewPortHandler = viewPortHandler
        self.animator = animator
        
        super.init()
    }
    
    open func drawData(context: CGContext) { }
    
    open func drawValues(context: CGContext) { }
    
    open func drawExtras(context: CGContext) { }
    
    open func drawHighlighted(context: CGContext, indices: [HighlightChart]) { }
    
    internal func isInBoundsX(entry e: DataEntryChart, dataSet: ProtocolBarLineScatterCandleBubbleChartDataSet) -> Bool
    {
        let entryIndex = dataSet.entryIndex(entry: e)
        return Double(entryIndex) < Double(dataSet.entryCount) * animator.phaseX
    }
    
    internal func xBounds(chart: DataProviderBarLineScatterCandleBubbleChart,
                          dataSet: ProtocolBarLineScatterCandleBubbleChartDataSet,
                          animator: AnimatorChart?) -> XBounds
    {
        return XBounds(chart: chart, dataSet: dataSet, animator: animator)
    }
    
    internal func shouldDrawValues(forDataSet set: ProtocolChartDataSet) -> Bool
    {
        return set.isVisible && (set.isDrawValuesEnabled || set.isDrawIconsEnabled)
    }
    
    open func initBuffers() { }
    
    open func isDrawingValuesAllowed(dataProvider: DataProviderChart?) -> Bool
    {
        guard let data = dataProvider?.data else { return false }
        return data.entryCount < Int(CGFloat(dataProvider?.maxVisibleCount ?? 0) * viewPortHandler.scaleX)
    }
    
    open class XBounds
    {
        open var min: Int = 0
        
        open var max: Int = 0
        
        open var range: Int = 0
        
        public init()
        {
            
        }
        
        public init(chart: DataProviderBarLineScatterCandleBubbleChart,
                    dataSet: ProtocolBarLineScatterCandleBubbleChartDataSet,
                    animator: AnimatorChart?)
        {
            self.set(chart: chart, dataSet: dataSet, animator: animator)
        }
        
        open func set(chart: DataProviderBarLineScatterCandleBubbleChart,
                      dataSet: ProtocolBarLineScatterCandleBubbleChartDataSet,
                      animator: AnimatorChart?)
        {
            let phaseX = Swift.max(0.0, Swift.min(1.0, animator?.phaseX ?? 1.0))
            
            let low = chart.lowestVisibleX
            let high = chart.highestVisibleX
            
            let entryFrom = dataSet.entryForXValue(low, closestToY: .nan, rounding: .down)
            let entryTo = dataSet.entryForXValue(high, closestToY: .nan, rounding: .up)
            
            self.min = entryFrom == nil ? 0 : dataSet.entryIndex(entry: entryFrom!)
            self.max = entryTo == nil ? 0 : dataSet.entryIndex(entry: entryTo!)
            range = Int(Double(self.max - self.min) * phaseX)
        }
    }
    
    public func createAccessibleHeader(usingChart chart: ChartViewBase, andData data: DataOfChart, withDefaultDescription defaultDescription: String) -> NSUIAccessibilityElement {
        return AccessibleHeader.create(usingChart: chart, andData: data, withDefaultDescription: defaultDescription)
    }
}

extension BarLineScatterCandleBubbleRender.XBounds: RangeExpression {
    public func relative<C>(to collection: C) -> Swift.Range<Int>
    where C : Collection, Bound == C.Index
    {
        return Swift.Range<Int>(min...min + range)
    }
    
    public func contains(_ element: Int) -> Bool {
        return (min...min + range).contains(element)
    }
}

extension BarLineScatterCandleBubbleRender.XBounds: Sequence {
    public struct Iterator: IteratorProtocol {
        private var iterator: IndexingIterator<ClosedRange<Int>>
        
        fileprivate init(min: Int, max: Int) {
            self.iterator = (min...max).makeIterator()
        }
        
        public mutating func next() -> Int? {
            return self.iterator.next()
        }
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(min: self.min, max: self.min + self.range)
    }
}

extension BarLineScatterCandleBubbleRender.XBounds: CustomDebugStringConvertible
{
    public var debugDescription: String
    {
        return "min:\(self.min), max:\(self.max), range:\(self.range)"
    }
}

