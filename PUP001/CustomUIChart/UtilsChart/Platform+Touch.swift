//
//  Platform+Touch.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

#if canImport(UIKit)
import UIKit

public typealias NSUIEvent = UIEvent
public typealias NSUITouch = UITouch

@objc
extension NSUIView {
    public final override func touchesBegan(_ touch: Set<NSUITouch>, with event: NSUIEvent?)
    {
        self.nsuiTouchesBegan(touch, withEvent: event)
    }
    
    public final override func touchesMoved(_ touch: Set<NSUITouch>, with event: NSUIEvent?)
    {
        self.nsuiTouchesMoved(touch, withEvent: event)
    }
    
    public final override func touchesEnded(_ touches: Set<NSUITouch>, with event: NSUIEvent?)
    {
        self.nsuiTouchesEnded(touches, withEvent: event)
    }
    
    public final override func touchesCancelled(_ touches: Set<NSUITouch>, with event: NSUIEvent?)
    {
        self.nsuiTouchesCancelled(touches, withEvent: event)
    }
    
    open func nsuiTouchesBegan(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.touchesBegan(touches, with: event!)
    }
    
    open func nsuiTouchesMoved(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.touchesMoved(touches, with: event!)
    }
    
    open func nsuiTouchesEnded(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.touchesEnded(touches, with: event!)
    }
    
    open func nsuiTouchesCancelled(_ touches: Set<NSUITouch>?, withEvent event: NSUIEvent?)
    {
        super.touchesCancelled(touches!, with: event!)
    }
}

extension UIView
{
    @objc final var nsuiGestureRecognizers: [NSUIGestureRecognizer]?
    {
        return self.gestureRecognizers
    }
}
#endif


#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public typealias NSUIEvent = NSEvent
public typealias NSUITouch = NSTouch

@objc
extension NSUIView
{
    public final override func touchesBegan(with event: NSEvent)
    {
        self.nsuiTouchesBegan(event.touches(matching: .any, in: self), withEvent: event)
    }
    
    public final override func touchesEnded(with event: NSEvent)
    {
        self.nsuiTouchesEnded(event.touches(matching: .any, in: self), withEvent: event)
    }
    
    public final override func touchesMoved(with event: NSEvent)
    {
        self.nsuiTouchesMoved(event.touches(matching: .any, in: self), withEvent: event)
    }
    
    open override func touchesCancelled(with event: NSEvent)
    {
        self.nsuiTouchesCancelled(event.touches(matching: .any, in: self), withEvent: event)
    }
    
    open func nsuiTouchesBegan(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.touchesBegan(with: event!)
    }
    
    open func nsuiTouchesMoved(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.touchesMoved(with: event!)
    }
    
    open func nsuiTouchesEnded(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.touchesEnded(with: event!)
    }
    
    open func nsuiTouchesCancelled(_ touches: Set<NSUITouch>?, withEvent event: NSUIEvent?)
    {
        super.touchesCancelled(with: event!)
    }
}

extension NSTouch
{
    func locationInView(view: NSView) -> NSPoint
    {
        let n = self.normalizedPosition
        let b = view.bounds
        return NSPoint(
            x: b.origin.x + b.size.width * n.x,
            y: b.origin.y + b.size.height * n.y
        )
    }
}
#endif

