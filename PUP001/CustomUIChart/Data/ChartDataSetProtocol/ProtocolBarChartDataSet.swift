//
//  BarChartDataSetProtocol.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc
public protocol ProtocolBarChartDataSet: ProtocolBarLineScatterCandleBubbleChartDataSet
{
    var isStacked: Bool { get }
    
    var stackSize: Int { get }
    
    var barShadowColor: NSUIColor { get set }
    
    var barBorderWidth : CGFloat { get set }

    var barBorderColor: NSUIColor { get set }

    var highlightAlpha: CGFloat { get set }
    
    var stackLabels: [String] { get set }
}

