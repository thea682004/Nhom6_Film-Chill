//
//  Platform.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit


public typealias ParagraphStyle = NSParagraphStyle
public typealias MutableParagraphStyle = NSMutableParagraphStyle
public typealias TextAlignment = NSTextAlignment
public typealias NSUIFont = UIFont
public typealias NSUIImage = UIImage
public typealias NSUIScrollView = UIScrollView
public typealias NSUIScreen = UIScreen
public typealias NSUIDisplayLink = CADisplayLink

extension NSUIColor
{
    var nsuirgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        return (red: red, green: green, blue: blue, alpha: alpha)
    }
}

open class NSUIView: UIView
{
    @objc var nsuiLayer: CALayer?
    {
        return self.layer
    }
}

extension UIScrollView
{
    @objc var nsuiIsScrollEnabled: Bool
    {
        get { return isScrollEnabled }
        set { isScrollEnabled = newValue }
    }
}

extension UIScreen
{
    @objc final var nsuiScale: CGFloat
    {
        return self.scale
    }
}

func NSUIMainScreen() -> NSUIScreen?
{
    return NSUIScreen.main
}

#endif

#if os(OSX)
import Cocoa
import Quartz

public typealias ParagraphStyle = NSParagraphStyle
public typealias MutableParagraphStyle = NSMutableParagraphStyle
public typealias TextAlignment = NSTextAlignment
public typealias NSUIFont = NSFont
public typealias NSUIImage = NSImage
public typealias NSUIScrollView = NSScrollView
public typealias NSUIScreen = NSScreen

public class NSUIDisplayLink
{
    private var timer: Timer?
    private var displayLink: CVDisplayLink?
    private var _timestamp: CFTimeInterval = 0.0
    
    private weak var _target: AnyObject?
    private var _selector: Selector
    
    public var timestamp: CFTimeInterval
    {
        return _timestamp
    }
    
    init(target: AnyObject, selector: Selector)
    {
        _target = target
        _selector = selector
        
        if CVDisplayLinkCreateWithActiveCGDisplays(&displayLink) == kCVReturnSuccess
        {
            
            CVDisplayLinkSetOutputCallback(displayLink!, { (displayLink, inNow, inOutputTime, flagsIn, flagsOut, userData) -> CVReturn in
                
                let _self = unsafeBitCast(userData, to: NSUIDisplayLink.self)
                
                _self._timestamp = CFAbsoluteTimeGetCurrent()
                _self._target?.performSelector(onMainThread: _self._selector, with: _self, waitUntilDone: false)
                
                return kCVReturnSuccess
            }, Unmanaged.passUnretained(self).toOpaque())
        }
        else
        {
            timer = Timer(timeInterval: 1.0 / 60.0, target: target, selector: selector, userInfo: nil, repeats: true)
        }
    }
    
    deinit
    {
        stop()
    }
    
    open func add(to runloop: RunLoop, forMode mode: RunLoop.Mode)
    {
        if displayLink != nil
        {
            CVDisplayLinkStart(displayLink!)
        }
        else if timer != nil
        {
            runloop.add(timer!, forMode: mode)
        }
    }
    
    open func remove(from: RunLoop, forMode: RunLoop.Mode)
    {
        stop()
    }
    
    private func stop()
    {
        if displayLink != nil
        {
            CVDisplayLinkStop(displayLink!)
        }
        if timer != nil
        {
            timer?.invalidate()
        }
    }
}

extension NSUIColor
{
    var nsuirgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard let colorSpaceModel = cgColor.colorSpace?.model else {
            return nil
        }
        guard colorSpaceModel == .rgb else {
            return nil
        }
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension NSView
{
    final var nsuiGestureRecognizers: [NSGestureRecognizer]?
    {
        return self.gestureRecognizers
    }
}

extension NSScrollView
{
    var nsuiIsScrollEnabled: Bool
    {
        get { return scrollEnabled }
        set { scrollEnabled = newValue }
    }
}

open class NSUIView: NSView
{
    private let role: NSAccessibility.Role = .list
    
    public override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        setAccessibilityRole(role)
    }
    
    required public init?(coder decoder: NSCoder)
    {
        super.init(coder: decoder)
        setAccessibilityRole(role)
    }
    
    public final override var isFlipped: Bool
    {
        return true
    }
    
    func setNeedsDisplay()
    {
        self.setNeedsDisplay(self.bounds)
    }
    
    open var backgroundColor: NSUIColor?
    {
        get
        {
            return self.layer?.backgroundColor == nil
            ? nil
            : NSColor(cgColor: self.layer!.backgroundColor!)
        }
        set
        {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue == nil ? nil : newValue!.cgColor
        }
    }
    
    final var nsuiLayer: CALayer?
    {
        return self.layer
    }
}

extension NSFont
{
    var lineHeight: CGFloat
    {
        return self.boundingRectForFont.size.height
    }
}

extension NSScreen
{
    final var nsuiScale: CGFloat
    {
        return self.backingScaleFactor
    }
}

extension NSImage
{
    var cgImage: CGImage?
    {
        return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
}

extension NSScrollView
{
    var scrollEnabled: Bool
    {
        get
        {
            return true
        }
        set {
        }
    }
}

func NSUIMainScreen() -> NSUIScreen?
{
    return NSUIScreen.main
}

#endif
