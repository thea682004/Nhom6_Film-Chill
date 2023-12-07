//
//  LegendEnry.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc(ChartLegendEntry)
open class LegendEntryChart: NSObject
{
    public override init()
    {
        super.init()
    }
    
    @objc public init(label: String?)
    {
        self.label = label
    }

    @objc open var label: String?

    @objc open var labelColor: NSUIColor?

    @objc open var form: LegendChart.Form = .default
    
    @objc open var formSize: CGFloat = CGFloat.nan
    
    @objc open var formLineWidth: CGFloat = CGFloat.nan
    
    @objc open var formLineDashPhase: CGFloat = 0.0
    
    @objc open var formLineDashLengths: [CGFloat]?
    
    @objc open var formColor: NSUIColor?
}

