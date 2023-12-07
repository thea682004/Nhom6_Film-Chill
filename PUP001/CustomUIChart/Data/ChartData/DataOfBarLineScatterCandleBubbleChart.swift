//
//  BarLineScatterCandleBubbleChartData.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

open class DataOfBarLineScatterCandleBubbleChart: DataOfChart
{
    public required init()
    {
        super.init()
    }
    
    public override init(dataSets: [ProtocolChartDataSet])
    {
        super.init(dataSets: dataSets)
    }

    public required init(arrayLiteral elements: ProtocolChartDataSet...)
    {
        super.init(dataSets: elements)
    }
}

