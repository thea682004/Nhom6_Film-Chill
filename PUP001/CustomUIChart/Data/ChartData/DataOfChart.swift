//
//  ChartData.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

open class DataOfChart: NSObject, ExpressibleByArrayLiteral
{

    @objc public internal(set) var xMax = -Double.greatestFiniteMagnitude
    @objc public internal(set) var xMin = Double.greatestFiniteMagnitude
    @objc public internal(set) var yMax = -Double.greatestFiniteMagnitude
    @objc public internal(set) var yMin = Double.greatestFiniteMagnitude
    var leftAxisMax = -Double.greatestFiniteMagnitude
    var leftAxisMin = Double.greatestFiniteMagnitude
    var rightAxisMax = -Double.greatestFiniteMagnitude
    var rightAxisMin = Double.greatestFiniteMagnitude

    @objc open var accessibilityEntryLabelPrefix: String?
    
    @objc open var accessibilityEntryLabelSuffix: String?
    
    @objc open var accessibilityEntryLabelSuffixIsCount: Bool = false
    
    var _dataSets = [Element]()
    
    public override required init()
    {
        super.init()
    }

    public required init(arrayLiteral elements: Element...)
    {
        super.init()
        self.dataSets = elements
    }

    @objc public init(dataSets: [Element])
    {
        super.init()
        self.dataSets = dataSets
    }
    
    @objc public convenience init(dataSet: Element)
    {
        self.init(dataSets: [dataSet])
    }

    @objc open func notifyDataChanged()
    {
        calcMinMax()
    }
    
    @objc open func calcMinMaxY(fromX: Double, toX: Double)
    {
        forEach { $0.calcMinMaxY(fromX: fromX, toX: toX) }
        
        calcMinMax()
    }
    
    @objc open func calcMinMax()
    {
        leftAxisMax = -.greatestFiniteMagnitude
        leftAxisMin = .greatestFiniteMagnitude
        rightAxisMax = -.greatestFiniteMagnitude
        rightAxisMin = .greatestFiniteMagnitude
        yMax = -.greatestFiniteMagnitude
        yMin = .greatestFiniteMagnitude
        xMax = -.greatestFiniteMagnitude
        xMin = .greatestFiniteMagnitude

        forEach { calcMinMax(dataSet: $0) }

        let firstLeft = getFirstLeft(dataSets: dataSets)
        
        if firstLeft !== nil
        {
            leftAxisMax = firstLeft!.yMax
            leftAxisMin = firstLeft!.yMin

            for dataSet in _dataSets where dataSet.axisDependency == .left
            {
                if dataSet.yMin < leftAxisMin
                {
                    leftAxisMin = dataSet.yMin
                }

                if dataSet.yMax > leftAxisMax
                {
                    leftAxisMax = dataSet.yMax
                }
            }
        }
        
        let firstRight = getFirstRight(dataSets: dataSets)
        
        if firstRight !== nil
        {
            rightAxisMax = firstRight!.yMax
            rightAxisMin = firstRight!.yMin
            
            for dataSet in _dataSets where dataSet.axisDependency == .right
            {
                if dataSet.yMin < rightAxisMin
                {
                    rightAxisMin = dataSet.yMin
                }

                if dataSet.yMax > rightAxisMax
                {
                    rightAxisMax = dataSet.yMax
                }
            }
        }
    }

    @objc open func calcMinMax(entry e: DataEntryChart, axis: YAxisChart.AxisDependency)
    {
        xMax = Swift.max(xMax, e.x)
        xMin = Swift.min(xMin, e.x)
        yMax = Swift.max(yMax, e.y)
        yMin = Swift.min(yMin, e.y)

        switch axis
        {
        case .left:
            leftAxisMax = Swift.max(leftAxisMax, e.y)
            leftAxisMin = Swift.min(leftAxisMin, e.y)

        case .right:
            rightAxisMax = Swift.max(rightAxisMax, e.y)
            rightAxisMin = Swift.min(rightAxisMin, e.y)
        }
    }
    
    @objc open func calcMinMax(dataSet d: Element)
    {
        xMax = Swift.max(xMax, d.xMax)
        xMin = Swift.min(xMin, d.xMin)
        yMax = Swift.max(yMax, d.yMax)
        yMin = Swift.min(yMin, d.yMin)

        switch d.axisDependency
        {
        case .left:
            leftAxisMax = Swift.max(leftAxisMax, d.yMax)
            leftAxisMin = Swift.min(leftAxisMin, d.yMin)

        case .right:
            rightAxisMax = Swift.max(rightAxisMax, d.yMax)
            rightAxisMin = Swift.min(rightAxisMin, d.yMin)
        }
    }
    
    @objc open var dataSetCount: Int
    {
        return dataSets.count
    }

    @objc open func getYMin(axis: YAxisChart.AxisDependency) -> Double
    {
        switch axis
        {
        case .left:
            if leftAxisMin == .greatestFiniteMagnitude
            {
                return rightAxisMin
            }
            else
            {
                return leftAxisMin
            }

        case .right:
            if rightAxisMin == .greatestFiniteMagnitude
            {
                return leftAxisMin
            }
            else
            {
                return rightAxisMin
            }
        }
    }
    
    @objc open func getYMax(axis: YAxisChart.AxisDependency) -> Double
    {
        if axis == .left
        {
            if leftAxisMax == -.greatestFiniteMagnitude
            {
                return rightAxisMax
            }
            else
            {
                return leftAxisMax
            }
        }
        else
        {
            if rightAxisMax == -.greatestFiniteMagnitude
            {
                return leftAxisMax
            }
            else
            {
                return rightAxisMax
            }
        }
    }
    
    @objc open var dataSets: [Element]
    {
        get
        {
            return _dataSets
        }
        set
        {
            _dataSets = newValue
            notifyDataChanged()
        }
    }

    @objc open func entry(for highlight: HighlightChart) -> DataEntryChart?
    {
        guard highlight.dataSetIndex < dataSets.endIndex else { return nil }
        return self[highlight.dataSetIndex].entryForXValue(highlight.x, closestToY: highlight.y)
    }
    
    @objc open func dataSet(forLabel label: String, ignorecase: Bool) -> Element?
    {
        guard let index = index(forLabel: label, ignoreCase: ignorecase) else { return nil }
        return self[index]
    }
    
    @objc(dataSetAtIndex:)
    open func dataSet(at index: Index) -> Element?
    {
        guard dataSets.indices.contains(index) else { return nil }
        return self[index]
    }

    @objc @discardableResult open func removeDataSet(_ dataSet: Element) -> Element?
    {
        guard let index = firstIndex(where: { $0 === dataSet }) else { return nil }
        return remove(at: index)
    }

    @objc(addEntry:dataSetIndex:)
    open func appendEntry(_ e: DataEntryChart, toDataSet dataSetIndex: Index)
    {
        guard dataSets.indices.contains(dataSetIndex) else {
            return print("ChartData.addEntry() - Cannot add Entry because dataSetIndex too high or too low.", terminator: "\n")
        }

        let set = self[dataSetIndex]
        if !set.addEntry(e) { return }
        calcMinMax(entry: e, axis: set.axisDependency)
    }

    @objc @discardableResult open func removeEntry(_ entry: DataEntryChart, dataSetIndex: Index) -> Bool
    {
        guard dataSets.indices.contains(dataSetIndex) else { return false }

        let removed = self[dataSetIndex].removeEntry(entry)
        
        if removed
        {
            calcMinMax()
        }
        
        return removed
    }
    
    @objc @discardableResult open func removeEntry(xValue: Double, dataSetIndex: Index) -> Bool
    {
        guard
            dataSets.indices.contains(dataSetIndex),
            let entry = self[dataSetIndex].entryForXValue(xValue, closestToY: .nan)
            else { return false }

        return removeEntry(entry, dataSetIndex: dataSetIndex)
    }
    
    @objc open func getDataSetForEntry(_ e: DataEntryChart) -> Element?
    {
        return first { $0.entryForXValue(e.x, closestToY: e.y) === e }
    }

    @objc open func index(of dataSet: Element) -> Index
    {
        return firstIndex(where: { $0 === dataSet }) ?? -1
    }
    
    @objc open func getFirstLeft(dataSets: [Element]) -> Element?
    {
        return first { $0.axisDependency == .left }
    }
    
    @objc open func getFirstRight(dataSets: [Element]) -> Element?
    {
        return first { $0.axisDependency == .right }
    }
    
    @objc open var colors: [NSUIColor]
    {
        return reduce(into: []) { $0 += $1.colors }
    }
    
    @objc open func setValueFormatter(_ formatter: FormatterValue)
    {
        forEach { $0.valueFormatter = formatter }
    }
    
    @objc open func setValueTextColor(_ color: NSUIColor)
    {
        forEach { $0.valueTextColor = color }
    }
    
    @objc open func setValueFont(_ font: NSUIFont)
    {
        forEach { $0.valueFont = font }
    }

    @objc open func setDrawValues(_ enabled: Bool)
    {
        forEach { $0.drawValuesEnabled = enabled }
    }
    
    @objc open var isHighlightEnabled: Bool
    {
        get { return allSatisfy { $0.isHighlightEnabled } }
        set { forEach { $0.highlightEnabled = newValue } }
    }

    @objc open func clearValues()
    {
        removeAll(keepingCapacity: false)
    }
    
    @objc open func contains(dataSet: Element) -> Bool
    {
        return contains { $0 === dataSet }
    }
    
    @objc open var entryCount: Int
    {
        return reduce(0) { return $0 + $1.entryCount }
    }

    @objc open var maxEntryCountSet: Element?
    {
        return self.max { $0.entryCount < $1.entryCount }
    }
}

extension DataOfChart: MutableCollection
{
    public typealias Index = Int
    public typealias Element = ProtocolChartDataSet

    public var startIndex: Index
    {
        return dataSets.startIndex
    }

    public var endIndex: Index
    {
        return dataSets.endIndex
    }

    public func index(after: Index) -> Index
    {
        return dataSets.index(after: after)
    }

    public subscript(position: Index) -> Element
    {
        get { return dataSets[position] }
        set { self._dataSets[position] = newValue }
    }
}

extension DataOfChart: RandomAccessCollection
{
    public func index(before: Index) -> Index
    {
        return dataSets.index(before: before)
    }
}

extension DataOfChart
{
    @objc(addDataSet:)
    public func append(_ newElement: Element)
    {
        _dataSets.append(newElement)
        calcMinMax(dataSet: newElement)
    }

    @objc(removeDataSetByIndex:)
    public func remove(at position: Index) -> Element
    {
        let element = _dataSets.remove(at: position)
        calcMinMax()
        return element
    }

    public func removeFirst() -> Element
    {
        assert(!(self is DataOfCombinedChart), "\(#function) not supported for CombinedData")

        let element = _dataSets.removeFirst()
        notifyDataChanged()
        return element
    }

    public func removeFirst(_ n: Int)
    {
        assert(!(self is DataOfCombinedChart), "\(#function) not supported for CombinedData")

        _dataSets.removeFirst(n)
        notifyDataChanged()
    }

    public func removeLast() -> Element
    {
        assert(!(self is DataOfCombinedChart), "\(#function) not supported for CombinedData")

        let element = _dataSets.removeLast()
        notifyDataChanged()
        return element
    }

    public func removeLast(_ n: Int)
    {
        assert(!(self is DataOfCombinedChart), "\(#function) not supported for CombinedData")

        _dataSets.removeLast(n)
        notifyDataChanged()
    }

    public func removeSubrange<R>(_ bounds: R) where R : RangeExpression, Index == R.Bound
    {
        assert(!(self is DataOfCombinedChart), "\(#function) not supported for CombinedData")

        _dataSets.removeSubrange(bounds)
        notifyDataChanged()
    }

    public func removeAll(keepingCapacity keepCapacity: Bool)
    {
        assert(!(self is DataOfCombinedChart), "\(#function) not supported for CombinedData")

        _dataSets.removeAll(keepingCapacity: keepCapacity)
        notifyDataChanged()
    }

    public func replaceSubrange<C>(_ subrange: Swift.Range<Index>, with newElements: C) where C : Collection, Element == C.Element
    {
        assert(!(self is DataOfCombinedChart), "\(#function) not supported for CombinedData")

        _dataSets.replaceSubrange(subrange, with: newElements)
        newElements.forEach { self.calcMinMax(dataSet: $0) }
    }
}

extension DataOfChart
{
    public func index(forLabel label: String, ignoreCase: Bool) -> Index?
    {
        return ignoreCase
            ? firstIndex { $0.label?.caseInsensitiveCompare(label) == .orderedSame }
            : firstIndex { $0.label == label }
    }

    public subscript(label label: String, ignoreCase ignoreCase: Bool) -> Element?
    {
        guard let index = index(forLabel: label, ignoreCase: ignoreCase) else { return nil }
        return self[index]
    }

    public subscript(entry entry: DataEntryChart) -> Element?
    {
        assert(!(self is DataOfCombinedChart), "\(#function) not supported for CombinedData")

        guard let index = firstIndex(where: { $0.entryForXValue(entry.x, closestToY: entry.y) === entry }) else { return nil }
        return self[index]
    }
}

