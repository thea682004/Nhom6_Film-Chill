//
//  BarLineScatterCandleBubbleChartDataSetProtocol.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc
public protocol ProtocolBarLineScatterCandleBubbleChartDataSet: ProtocolChartDataSet
{
    
    var highlightColor: NSUIColor { get set }
    var highlightLineWidth: CGFloat { get set }
    var highlightLineDashPhase: CGFloat { get set }
    var highlightLineDashLengths: [CGFloat]? { get set }
}

