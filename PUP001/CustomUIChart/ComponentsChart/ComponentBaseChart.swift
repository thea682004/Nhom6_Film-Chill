//
//  ComponentBase.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc(ChartComponentBase)
open class ComponentBaseChart: NSObject
{
    @objc open var enabled = true
    
    @objc open var xOffset = CGFloat(5.0)
    
    @objc open var yOffset = CGFloat(5.0)
    
    public override init()
    {
        super.init()
    }

    @objc open var isEnabled: Bool { return enabled }
}

