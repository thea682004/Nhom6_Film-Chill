//
//  Renderer.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

@objc(ChartRenderer)
public protocol RenderBarChart {
    
    var viewPortHandler: ViewPortHandler { get }
}

