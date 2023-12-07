//
//  ChartDataSet.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

@objc
public enum ChartDataSetRounding: Int
{
    case up = 0
    case down = 1
    case closest = 2
}

open class SetChartData: SetBaseChartData
{
    public required init()
    {
        entries = []
        
        super.init()
    }
    
    public override convenience init(label: String)
    {
        self.init(entries: [], label: label)
    }
    
    @objc public init(entries: [DataEntryChart], label: String)
    {
        self.entries = entries

        super.init(label: label)

        self.calcMinMax()
    }
    
    @objc public convenience init(entries: [DataEntryChart])
    {
        self.init(entries: entries, label: "DataSet")
    }
    
    @objc
    open private(set) var entries: [DataEntryChart]

    @objc
    public func replaceEntries(_ entries: [DataEntryChart]) {
        self.entries = entries
        notifyDataSetChanged()
    }

    internal var _yMax: Double = -Double.greatestFiniteMagnitude
    
    internal var _yMin: Double = Double.greatestFiniteMagnitude
    
    internal var _xMax: Double = -Double.greatestFiniteMagnitude
    
    internal var _xMin: Double = Double.greatestFiniteMagnitude
    
    open override func calcMinMax()
    {
        _yMax = -Double.greatestFiniteMagnitude
        _yMin = Double.greatestFiniteMagnitude
        _xMax = -Double.greatestFiniteMagnitude
        _xMin = Double.greatestFiniteMagnitude

        guard !isEmpty else { return }

        forEach(calcMinMax)
    }
    
    open override func calcMinMaxY(fromX: Double, toX: Double)
    {
        _yMax = -Double.greatestFiniteMagnitude
        _yMin = Double.greatestFiniteMagnitude

        guard !isEmpty else { return }
        
        let indexFrom = entryIndex(x: fromX, closestToY: .nan, rounding: .closest)
        var indexTo = entryIndex(x: toX, closestToY: .nan, rounding: .up)
        if indexTo == -1 { indexTo = entryIndex(x: toX, closestToY: .nan, rounding: .closest) }
        
        guard indexTo >= indexFrom else { return }
        self[indexFrom...indexTo].forEach(calcMinMaxY)
    }
    
    @objc open func calcMinMaxX(entry e: DataEntryChart)
    {
        _xMin = Swift.min(e.x, _xMin)
        _xMax = Swift.max(e.x, _xMax)
    }
    
    @objc open func calcMinMaxY(entry e: DataEntryChart)
    {
        _yMin = Swift.min(e.y, _yMin)
        _yMax = Swift.max(e.y, _yMax)
    }
    
    internal func calcMinMax(entry e: DataEntryChart)
    {
        calcMinMaxX(entry: e)
        calcMinMaxY(entry: e)
    }
    
    @objc open override var yMin: Double { return _yMin }
    
    @objc open override var yMax: Double { return _yMax }
    
    @objc open override var xMin: Double { return _xMin }
    
    @objc open override var xMax: Double { return _xMax }
    
    @available(*, deprecated, message: "Use `count` instead")
    open override var entryCount: Int { return count }
    
    @available(*, deprecated, message: "Use `subscript(index:)` instead.")
    open override func entryForIndex(_ i: Int) -> DataEntryChart?
    {
        guard indices.contains(i) else {
            return nil
        }
        return self[i]
    }
    
    open override func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding) -> DataEntryChart?
    {
        let index = entryIndex(x: xValue, closestToY: yValue, rounding: rounding)
        if index > -1
        {
            return self[index]
        }
        return nil
    }
    
    open override func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double) -> DataEntryChart?
    {
        return entryForXValue(xValue, closestToY: yValue, rounding: .closest)
    }
    
    open override func entriesForXValue(_ xValue: Double) -> [DataEntryChart]
    {
        let match: (DataEntryChart) -> Bool = { $0.x == xValue }
        var partitioned = self.entries
        _ = partitioned.partition(by: match)
        let i = partitioned.partitionIndex(where: match)
        guard i < endIndex else { return [] }
        return partitioned[i...].prefix(while: match)
    }
  
    open override func entryIndex(
        x xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding) -> Int
    {
        var closest = partitionIndex { $0.x >= xValue }
        guard closest < endIndex else { return index(before: endIndex) }

        var closestXValue = self[closest].x

        switch rounding {
        case .up:
            if closestXValue < xValue && closest < index(before: endIndex)
            {
                formIndex(after: &closest)
            }

        case .down:
            if closestXValue > xValue && closest > startIndex
            {
                formIndex(before: &closest)
            }

        case .closest:
            if closest > startIndex {
                let distanceAfter = abs(self[closest].x - xValue)
                let distanceBefore = abs(self[index(before: closest)].x - xValue)
                if distanceBefore < distanceAfter
                {
                    closest = index(before: closest)
                }
                closestXValue = self[closest].x
            }
        }

        if !yValue.isNaN
        {
            while closest > startIndex && self[index(before: closest)].x == closestXValue
            {
                formIndex(before: &closest)
            }

            var closestYValue = self[closest].y
            var closestYIndex = closest

            while closest < index(before: endIndex)
            {
                formIndex(after: &closest)
                let value = self[closest]

                if value.x != closestXValue { break }
                if abs(value.y - yValue) <= abs(closestYValue - yValue)
                {
                    closestYValue = yValue
                    closestYIndex = closest
                }
            }

            closest = closestYIndex
        }
        
        return closest
    }
    
    @available(*, deprecated, message: "Use `firstIndex(of:)` or `lastIndex(of:)`")
    open override func entryIndex(entry e: DataEntryChart) -> Int
    {
        return firstIndex(of: e) ?? -1
    }

    @available(*, deprecated, message: "Use `append(_:)` instead", renamed: "append(_:)")
    @discardableResult open override func addEntry(_ e: DataEntryChart) -> Bool
    {
        append(e)
        return true
    }
    
    @discardableResult open override func addEntryOrdered(_ e: DataEntryChart) -> Bool
    {
        if let last = last, last.x > e.x
        {
            let startIndex = entryIndex(x: e.x, closestToY: e.y, rounding: .up)
            let closestIndex = self[startIndex...].lastIndex { $0.x < e.x }
                ?? startIndex
            calcMinMax(entry: e)
            entries.insert(e, at: closestIndex)
        }
        else
        {
            append(e)
        }
        
        return true
    }
    
    @available(*, renamed: "remove(_:)")
    open override func removeEntry(_ entry: DataEntryChart) -> Bool
    {
        remove(entry)
    }
    
    open func remove(_ entry: DataEntryChart) -> Bool
    {
        guard let index = firstIndex(of: entry) else { return false }
        _ = remove(at: index)
        return true
    }

    @available(*, deprecated, message: "Use `func removeFirst() -> ChartDataEntry` instead.")
    open override func removeFirst() -> Bool
    {
        let entry: DataEntryChart? = isEmpty ? nil : removeFirst()
        return entry != nil
    }
    
    @available(*, deprecated, message: "Use `func removeLast() -> ChartDataEntry` instead.")
    open override func removeLast() -> Bool
    {
        let entry: DataEntryChart? = isEmpty ? nil : removeLast()
        return entry != nil
    }

    @available(*, deprecated, message: "Use `removeAll(keepingCapacity:)` instead.")
    open override func clear()
    {
        removeAll(keepingCapacity: true)
    }
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! SetChartData
        
        copy.entries = entries
        copy._yMax = _yMax
        copy._yMin = _yMin
        copy._xMax = _xMax
        copy._xMin = _xMin

        return copy
    }
}

extension SetChartData: MutableCollection {
    public typealias Index = Int
    public typealias Element = DataEntryChart

    public var startIndex: Index {
        return entries.startIndex
    }

    public var endIndex: Index {
        return entries.endIndex
    }

    public func index(after: Index) -> Index {
        return entries.index(after: after)
    }

    @objc
    public subscript(position: Index) -> Element {
        get {
            return entries[position]
        }
        set {
            calcMinMax(entry: newValue)
            entries[position] = newValue
        }
    }
}

extension SetChartData: RandomAccessCollection {
    public func index(before: Index) -> Index {
        return entries.index(before: before)
    }
}

extension SetChartData: RangeReplaceableCollection {
    public func replaceSubrange<C>(_ subrange: Swift.Range<Index>, with newElements: C) where C : Collection, Element == C.Element {
        entries.replaceSubrange(subrange, with: newElements)
        notifyDataSetChanged()
    }
    
    public func append(_ newElement: Element) {
        calcMinMax(entry: newElement)
        entries.append(newElement)
    }

    public func remove(at position: Index) -> Element {
        let element = entries.remove(at: position)
        notifyDataSetChanged()
        return element
    }

    public func removeFirst() -> Element {
        let element = entries.removeFirst()
        notifyDataSetChanged()
        return element
    }

    public func removeFirst(_ n: Int) {
        entries.removeFirst(n)
        notifyDataSetChanged()
    }

    public func removeLast() -> Element {
        let element = entries.removeLast()
        notifyDataSetChanged()
        return element
    }

    public func removeLast(_ n: Int) {
        entries.removeLast(n)
        notifyDataSetChanged()
    }

    public func removeSubrange<R>(_ bounds: R) where R : RangeExpression, Index == R.Bound {
        entries.removeSubrange(bounds)
        notifyDataSetChanged()
    }

    @objc
    public func removeAll(keepingCapacity keepCapacity: Bool) {
        entries.removeAll(keepingCapacity: keepCapacity)
        notifyDataSetChanged()
    }
}

