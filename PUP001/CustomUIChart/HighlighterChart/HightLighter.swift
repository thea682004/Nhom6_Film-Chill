//
//  HightLighter.swift
//  PUP001
//
//  Created by chuottp on 19/08/2023.
//

import Foundation
import CoreGraphics

@objc(ChartHighlighter)
public protocol HighlighterChart: AnyObject
{
    func getHighlight(x: CGFloat, y: CGFloat) -> HighlightChart?
}

