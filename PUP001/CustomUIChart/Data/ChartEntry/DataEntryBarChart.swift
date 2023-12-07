//
//  BarChartDataEntry.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

open class DataEntryBarChart: DataEntryChart
{
    private var _yVals: [Double]?
    
    private var _ranges: [RangeChart]?
    
    private var _negativeSum: Double = 0.0
    
    private var _positiveSum: Double = 0.0
    
    public required init()
    {
        super.init()
    }
    
    public override init(x: Double, y: Double)
    {
        super.init(x: x, y: y)
    }
    
    public convenience init(x: Double, y: Double, data: Any?)
    {
        self.init(x: x, y: y)
        self.data = data
    }
    
    public convenience init(x: Double, y: Double, icon: NSUIImage?)
    {
        self.init(x: x, y: y)
        self.icon = icon
    }
    
    public convenience init(x: Double, y: Double, icon: NSUIImage?, data: Any?)
    {
        self.init(x: x, y: y)
        self.icon = icon
        self.data = data
    }
    
    @objc public init(x: Double, yValues: [Double])
    {
        super.init(x: x, y: DataEntryBarChart.calcSum(values: yValues))
        self._yVals = yValues
        calcPosNegSum()
        calcRanges()
    }

    @objc public convenience init(x: Double, yValues: [Double], icon: NSUIImage?)
    {
        self.init(x: x, yValues: yValues)
        self.icon = icon
    }

    @objc public convenience init(x: Double, yValues: [Double], data: Any?)
    {
        self.init(x: x, yValues: yValues)
        self.data = data
    }

    @objc public convenience init(x: Double, yValues: [Double], icon: NSUIImage?, data: Any?)
    {
        self.init(x: x, yValues: yValues)
        self.icon = icon
        self.data = data
    }
    
    @objc open func sumBelow(stackIndex: Int) -> Double
    {
        guard let yVals = _yVals, yVals.indices.contains(stackIndex) else
        {
            return 0
        }

        let remainder = yVals[stackIndex...].reduce(into: 0.0) { $0 += $1 }
        return remainder
    }
    
    @objc open var negativeSum: Double
    {
        return _negativeSum
    }
    
    @objc open var positiveSum: Double
    {
        return _positiveSum
    }

    var stackSize: Int { yValues?.count ?? 1}

    @objc open func calcPosNegSum()
    {
        (_negativeSum, _positiveSum) = _yVals?.reduce(into: (0,0)) { (result, y) in
            if y < 0
            {
                result.0 += -y
            }
            else
            {
                result.1 += y
            }
        } ?? (0,0)
    }
    
    @objc open func calcRanges()
    {
        guard let values = yValues, !values.isEmpty else { return }

        if _ranges == nil
        {
            _ranges = [RangeChart]()
        }
        else
        {
            _ranges!.removeAll()
        }
        
        _ranges!.reserveCapacity(values.count)
        
        var negRemain = -negativeSum
        var posRemain: Double = 0.0
        
        for value in values
        {
            if value < 0
            {
                _ranges!.append(RangeChart(from: negRemain, to: negRemain - value))
                negRemain -= value
            }
            else
            {
                _ranges!.append(RangeChart(from: posRemain, to: posRemain + value))
                posRemain += value
            }
        }
    }
    
    @objc open var isStacked: Bool { return _yVals != nil }
    
    @objc open var yValues: [Double]?
    {
        get { return self._yVals }
        set
        {
            self.y = DataEntryBarChart.calcSum(values: newValue ?? [])
            self._yVals = newValue
            calcPosNegSum()
            calcRanges()
        }
    }
    
    @objc open var ranges: [RangeChart]?
    {
        return _ranges
    }
    
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! DataEntryBarChart
        copy._yVals = _yVals
        copy.y = y
        copy._negativeSum = _negativeSum
        copy._positiveSum = _positiveSum
        return copy
    }
    
    private static func calcSum(values: [Double]) -> Double
    {
        values.reduce(into: 0, +=)
    }
}

