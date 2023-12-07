//
//  Description.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(Cocoa)
import Cocoa
#endif

@objc(ChartDescription)
open class DescriptionChart: ComponentBaseChart
{
    public override init()
    {
        #if os(tvOS)
        font = .systemFont(ofSize: 23)
        #elseif os(OSX)
        font = .systemFont(ofSize: NSUIFont.systemFontSize)
        #else
        font = .systemFont(ofSize: 8.0)
        #endif
        
        super.init()
    }
    
    @objc open var text: String?
    
    open var position: CGPoint? = nil
    
    @objc open var textAlign: TextAlignment = TextAlignment.right
    
    @objc open var font: NSUIFont
    
    @objc open var textColor = NSUIColor.labelOrBlack
}

